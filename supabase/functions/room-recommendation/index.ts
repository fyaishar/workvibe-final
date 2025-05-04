// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.7.1";

interface RoomRecommendationRequest {
  userId: string;
}

interface RoomRecommendationResponse {
  recommendedRoomType: string;
  reasons: string[];
  activeSessionsInRooms: Record<string, number>;
}

serve(async (req: Request) => {
  // CORS headers
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      }
    });
  }

  try {
    // Get the authorization header
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "Unauthorized" }),
        { 
          status: 401,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
          }
        }
      );
    }

    // Create a Supabase client with the auth header
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: authHeader } } }
    );
    
    // Get the authenticated user
    const {
      data: { user },
    } = await supabaseClient.auth.getUser();

    if (!user) {
      return new Response(
        JSON.stringify({ error: "Unauthorized" }),
        { 
          status: 401,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
          }
        }
      );
    }
    
    // Parse the request body
    const { userId } = await req.json() as RoomRecommendationRequest;
    
    // Security check: Users can only get recommendations for themselves
    if (userId !== user.id) {
      return new Response(
        JSON.stringify({ error: "Forbidden: You can only get recommendations for yourself" }),
        { 
          status: 403,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
          }
        }
      );
    }
    
    // 1. Get user's historical room preferences
    const { data: userSessions, error: sessionsError } = await supabaseClient
      .from("sessions")
      .select("room_type, start_time")
      .eq("user_id", userId)
      .order("start_time", { ascending: false })
      .limit(50);
      
    if (sessionsError) {
      return new Response(
        JSON.stringify({ error: sessionsError.message }),
        { 
          status: 500,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
          }
        }
      );
    }
    
    // 2. Get current active sessions in each room
    const { data: rooms, error: roomsError } = await supabaseClient
      .from("rooms")
      .select("type, active_sessions");
      
    if (roomsError) {
      return new Response(
        JSON.stringify({ error: roomsError.message }),
        { 
          status: 500,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
          }
        }
      );
    }
    
    // Convert rooms data to a map of room type -> active sessions
    const activeSessionsMap: Record<string, number> = {};
    rooms.forEach(room => {
      activeSessionsMap[room.type] = room.active_sessions;
    });
    
    // 3. Determine time of day
    const hour = new Date().getHours();
    const timeOfDay = 
      hour >= 5 && hour < 12 ? "morning" :
      hour >= 12 && hour < 18 ? "afternoon" :
      "evening";
    
    // 4. Get the recommendation
    const recommendation = calculateRoomRecommendation(
      userSessions,
      activeSessionsMap,
      timeOfDay
    );
    
    // Return the recommendation
    return new Response(
      JSON.stringify(recommendation),
      { 
        status: 200,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*"
        }
      }
    );
    
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        status: 500,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*"
        }
      }
    );
  }
});

function calculateRoomRecommendation(
  userSessions: any[],
  activeSessionsMap: Record<string, number>,
  timeOfDay: string
): RoomRecommendationResponse {
  // Initialize response
  const response: RoomRecommendationResponse = {
    recommendedRoomType: "",
    reasons: [],
    activeSessionsInRooms: activeSessionsMap
  };
  
  // Count room usage frequency
  const roomUsage: Record<string, number> = {};
  userSessions.forEach(session => {
    if (session.room_type) {
      roomUsage[session.room_type] = (roomUsage[session.room_type] || 0) + 1;
    }
  });
  
  // Calculate time-of-day patterns
  const timeOfDayPatterns: Record<string, Record<string, number>> = {
    morning: {},
    afternoon: {},
    evening: {}
  };
  
  userSessions.forEach(session => {
    if (session.room_type && session.start_time) {
      const sessionHour = new Date(session.start_time).getHours();
      const sessionTimeOfDay = 
        sessionHour >= 5 && sessionHour < 12 ? "morning" :
        sessionHour >= 12 && sessionHour < 18 ? "afternoon" :
        "evening";
      
      if (!timeOfDayPatterns[sessionTimeOfDay][session.room_type]) {
        timeOfDayPatterns[sessionTimeOfDay][session.room_type] = 0;
      }
      timeOfDayPatterns[sessionTimeOfDay][session.room_type]++;
    }
  });
  
  // Get the most used room by the user
  let mostUsedRoom = "";
  let mostUsedCount = 0;
  Object.entries(roomUsage).forEach(([room, count]) => {
    if (count > mostUsedCount) {
      mostUsedCount = count;
      mostUsedRoom = room;
    }
  });
  
  // Get the most used room for the current time of day
  let mostUsedRoomForTimeOfDay = "";
  let mostUsedCountForTimeOfDay = 0;
  Object.entries(timeOfDayPatterns[timeOfDay]).forEach(([room, count]) => {
    if (count > mostUsedCountForTimeOfDay) {
      mostUsedCountForTimeOfDay = count;
      mostUsedRoomForTimeOfDay = room;
    }
  });
  
  // Find the room with the lowest number of active sessions
  let leastBusyRoom = "";
  let leastBusyCount = Infinity;
  Object.entries(activeSessionsMap).forEach(([room, count]) => {
    if (count < leastBusyCount) {
      leastBusyCount = count;
      leastBusyRoom = room;
    }
  });
  
  // Algorithm to determine the best room recommendation
  let recommendedRoom = "";
  const reasons: string[] = [];
  
  // If user has a strong preference for a room at this time of day, recommend it
  if (mostUsedRoomForTimeOfDay && mostUsedCountForTimeOfDay >= 3) {
    recommendedRoom = mostUsedRoomForTimeOfDay;
    reasons.push(`You frequently use this room during the ${timeOfDay}`);
  } 
  // Otherwise, if they have a general preference, use that
  else if (mostUsedRoom) {
    recommendedRoom = mostUsedRoom;
    reasons.push("This is your most frequently used room");
  } 
  // If no preference, use the least busy room
  else {
    recommendedRoom = leastBusyRoom;
    reasons.push("This room is currently the least busy");
  }
  
  // Add additional reasons
  if (activeSessionsMap[recommendedRoom] === 0) {
    reasons.push("This room is currently empty");
  } else if (activeSessionsMap[recommendedRoom] < 3) {
    reasons.push("This room is not very crowded right now");
  }
  
  // Set the recommendation
  response.recommendedRoomType = recommendedRoom;
  response.reasons = reasons;
  
  return response;
} 
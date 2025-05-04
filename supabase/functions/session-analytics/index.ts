// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.7.1";

interface SessionAnalyticsRequest {
  userId: string;
  timeRange: "daily" | "weekly" | "monthly";
  startDate?: string;
  endDate?: string;
}

interface SessionAnalyticsResponse {
  totalSessionTime: number; // in minutes
  numberOfSessions: number;
  averageSessionDuration: number; // in minutes
  mostActiveHour: number; // 0-23 hour of day
  mostActiveDay?: number; // 0-6 day of week (for weekly/monthly ranges)
  sessionsPerDay: Record<string, number>;
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
    const { userId, timeRange, startDate, endDate } = await req.json() as SessionAnalyticsRequest;
    
    // Security check: Users can only get analytics for themselves
    if (userId !== user.id) {
      return new Response(
        JSON.stringify({ error: "Forbidden: You can only view your own analytics" }),
        { 
          status: 403,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
          }
        }
      );
    }
    
    // Calculate date ranges based on the timeRange
    const now = new Date();
    let startDateTime: Date;
    let endDateTime = endDate ? new Date(endDate) : now;
    
    if (startDate) {
      startDateTime = new Date(startDate);
    } else {
      switch (timeRange) {
        case "daily":
          startDateTime = new Date(now);
          startDateTime.setHours(0, 0, 0, 0);
          break;
        case "weekly":
          startDateTime = new Date(now);
          startDateTime.setDate(now.getDate() - 7);
          break;
        case "monthly":
          startDateTime = new Date(now);
          startDateTime.setMonth(now.getMonth() - 1);
          break;
        default:
          startDateTime = new Date(now);
          startDateTime.setHours(0, 0, 0, 0);
      }
    }
    
    // Query the sessions table for the specified user and time range
    const { data: sessions, error } = await supabaseClient
      .from("sessions")
      .select("*")
      .eq("user_id", userId)
      .gte("start_time", startDateTime.toISOString())
      .lte("end_time", endDateTime.toISOString())
      .order("start_time", { ascending: true });
      
    if (error) {
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
    
    // Calculate analytics
    const analytics: SessionAnalyticsResponse = calculateSessionAnalytics(sessions, timeRange);
    
    // Return the analytics
    return new Response(
      JSON.stringify(analytics),
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

function calculateSessionAnalytics(
  sessions: any[],
  timeRange: "daily" | "weekly" | "monthly"
): SessionAnalyticsResponse {
  // Initialize response
  const response: SessionAnalyticsResponse = {
    totalSessionTime: 0,
    numberOfSessions: sessions.length,
    averageSessionDuration: 0,
    mostActiveHour: 0,
    sessionsPerDay: {},
  };
  
  if (sessions.length === 0) {
    return response;
  }
  
  // For tracking most active hour
  const hourCounts: number[] = Array(24).fill(0);
  
  // For tracking most active day (for weekly/monthly)
  const dayCounts: number[] = Array(7).fill(0);
  
  // Track sessions per day for graphing
  const sessionsPerDay: Record<string, number> = {};
  
  // Process each session
  sessions.forEach(session => {
    const startTime = new Date(session.start_time);
    const endTime = session.end_time ? new Date(session.end_time) : new Date();
    
    // Calculate duration in minutes
    const durationMinutes = (endTime.getTime() - startTime.getTime()) / (1000 * 60);
    response.totalSessionTime += durationMinutes;
    
    // Track hour of day
    hourCounts[startTime.getHours()]++;
    
    // Track day of week
    dayCounts[startTime.getDay()]++;
    
    // Track sessions per day
    const dateKey = startTime.toISOString().split('T')[0];
    sessionsPerDay[dateKey] = (sessionsPerDay[dateKey] || 0) + 1;
  });
  
  // Calculate average session duration
  response.averageSessionDuration = response.totalSessionTime / sessions.length;
  
  // Find most active hour
  let maxHourCount = 0;
  for (let i = 0; i < 24; i++) {
    if (hourCounts[i] > maxHourCount) {
      maxHourCount = hourCounts[i];
      response.mostActiveHour = i;
    }
  }
  
  // Find most active day (only for weekly/monthly)
  if (timeRange !== "daily") {
    let maxDayCount = 0;
    for (let i = 0; i < 7; i++) {
      if (dayCounts[i] > maxDayCount) {
        maxDayCount = dayCounts[i];
        response.mostActiveDay = i;
      }
    }
  }
  
  // Add sessions per day
  response.sessionsPerDay = sessionsPerDay;
  
  return response;
} 
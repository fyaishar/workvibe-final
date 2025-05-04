// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.7.1";

// Schema validation types
interface Schema {
  type: string;
  properties?: Record<string, SchemaProperty>;
  required?: string[];
}

interface SchemaProperty {
  type: string;
  format?: string;
  enum?: string[];
  minimum?: number;
  maximum?: number;
  minLength?: number;
  maxLength?: number;
  pattern?: string;
}

// Validation function
function validateData(data: any, schema: Schema): { valid: boolean; errors: string[] } {
  const errors: string[] = [];
  
  // Check type
  if (schema.type === 'object' && typeof data !== 'object') {
    errors.push(`Expected an object, got ${typeof data}`);
    return { valid: false, errors };
  }
  
  // Check required properties
  if (schema.required) {
    for (const requiredProp of schema.required) {
      if (data[requiredProp] === undefined) {
        errors.push(`Missing required property: ${requiredProp}`);
      }
    }
  }
  
  // Check property types and formats
  if (schema.properties) {
    for (const [propName, propSchema] of Object.entries(schema.properties)) {
      const value = data[propName];
      
      // Skip if property is not provided and not required
      if (value === undefined) {
        continue;
      }
      
      // Validate type
      if (propSchema.type === 'string' && typeof value !== 'string') {
        errors.push(`Property ${propName} should be a string, got ${typeof value}`);
      } else if (propSchema.type === 'number' && typeof value !== 'number') {
        errors.push(`Property ${propName} should be a number, got ${typeof value}`);
      } else if (propSchema.type === 'boolean' && typeof value !== 'boolean') {
        errors.push(`Property ${propName} should be a boolean, got ${typeof value}`);
      } else if (propSchema.type === 'array' && !Array.isArray(value)) {
        errors.push(`Property ${propName} should be an array, got ${typeof value}`);
      }
      
      // Validate string formats
      if (propSchema.type === 'string' && typeof value === 'string') {
        // Validate enum
        if (propSchema.enum && !propSchema.enum.includes(value)) {
          errors.push(`Property ${propName} should be one of: ${propSchema.enum.join(', ')}, got ${value}`);
        }
        
        // Validate min/max length
        if (propSchema.minLength !== undefined && value.length < propSchema.minLength) {
          errors.push(`Property ${propName} should have a minimum length of ${propSchema.minLength}`);
        }
        if (propSchema.maxLength !== undefined && value.length > propSchema.maxLength) {
          errors.push(`Property ${propName} should have a maximum length of ${propSchema.maxLength}`);
        }
        
        // Validate pattern
        if (propSchema.pattern && !new RegExp(propSchema.pattern).test(value)) {
          errors.push(`Property ${propName} does not match the required pattern`);
        }
        
        // Validate format
        if (propSchema.format === 'email' && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) {
          errors.push(`Property ${propName} should be a valid email address`);
        } else if (propSchema.format === 'date-time' && isNaN(Date.parse(value))) {
          errors.push(`Property ${propName} should be a valid date-time string`);
        } else if (propSchema.format === 'uuid' && !/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(value)) {
          errors.push(`Property ${propName} should be a valid UUID`);
        }
      }
      
      // Validate number ranges
      if (propSchema.type === 'number' && typeof value === 'number') {
        if (propSchema.minimum !== undefined && value < propSchema.minimum) {
          errors.push(`Property ${propName} should be at least ${propSchema.minimum}`);
        }
        if (propSchema.maximum !== undefined && value > propSchema.maximum) {
          errors.push(`Property ${propName} should be at most ${propSchema.maximum}`);
        }
      }
    }
  }
  
  return { valid: errors.length === 0, errors };
}

// Request validation schemas
const schemas: Record<string, Schema> = {
  'session-analytics': {
    type: 'object',
    properties: {
      userId: { type: 'string', format: 'uuid' },
      timeRange: { type: 'string', enum: ['daily', 'weekly', 'monthly'] },
      startDate: { type: 'string', format: 'date-time' },
      endDate: { type: 'string', format: 'date-time' }
    },
    required: ['userId', 'timeRange']
  },
  'room-recommendation': {
    type: 'object',
    properties: {
      userId: { type: 'string', format: 'uuid' }
    },
    required: ['userId']
  },
  'start-session': {
    type: 'object',
    properties: {
      userId: { type: 'string', format: 'uuid' },
      status: { type: 'string' },
      currentProject: { type: 'string', format: 'uuid' },
      currentTask: { type: 'string', format: 'uuid' },
      roomType: { type: 'string' },
      startTime: { type: 'string', format: 'date-time' }
    },
    required: ['userId', 'status']
  },
  'end-session': {
    type: 'object',
    properties: {
      sessionId: { type: 'string', format: 'uuid' },
      endTime: { type: 'string', format: 'date-time' }
    },
    required: ['sessionId', 'endTime']
  }
};

serve(async (req: Request) => {
  // CORS headers
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, x-schema",
      }
    });
  }

  try {
    // Get the schema header
    const schemaName = req.headers.get("X-Schema");
    if (!schemaName || !schemas[schemaName]) {
      return new Response(
        JSON.stringify({ error: "Invalid or missing schema name in X-Schema header" }),
        { 
          status: 400, 
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
          }
        }
      );
    }
    
    // Get the request data
    const data = await req.json();
    
    // Validate the data against the schema
    const { valid, errors } = validateData(data, schemas[schemaName]);
    if (!valid) {
      return new Response(
        JSON.stringify({ error: "Validation failed", details: errors }),
        { 
          status: 400,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
          }
        }
      );
    }
    
    // If validation passes, forward the request to the appropriate endpoint
    const targetUrl = new URL(req.url);
    targetUrl.pathname = `${targetUrl.pathname}/${schemaName}`;
    
    // Forward the request
    const response = await fetch(targetUrl.toString(), {
      method: req.method,
      headers: req.headers,
      body: JSON.stringify(data)
    });
    
    // Return the response from the target endpoint
    return response;
    
  } catch (error) {
    return new Response(
      JSON.stringify({ error: "Validation error", message: error.message }),
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
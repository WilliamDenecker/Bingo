export type Database = {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string;
          display_name: string;
          created_at: string;
        };
        Insert: {
          id: string;
          display_name: string;
          created_at?: string;
        };
        Update: {
          id?: string;
          display_name?: string;
          created_at?: string;
        };
      };
      bingo_squares: {
        Row: {
          id: number;
          position: number;
          label: string;
        };
        Insert: {
          position: number;
          label: string;
        };
        Update: {
          position?: number;
          label?: string;
        };
      };
      user_squares: {
        Row: {
          user_id: string;
          square_id: number;
          is_done: boolean;
          completed_at: string | null;
        };
        Insert: {
          user_id: string;
          square_id: number;
          is_done?: boolean;
          completed_at?: string | null;
        };
        Update: {
          user_id?: string;
          square_id?: number;
          is_done?: boolean;
          completed_at?: string | null;
        };
      };
    };
    Views: Record<string, never>;
    Functions: Record<string, never>;
    Enums: Record<string, never>;
  };
};

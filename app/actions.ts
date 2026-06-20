"use server";

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";

export async function toggleSquare(squareId: number, currentDone: boolean) {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) throw new Error("Not authenticated");

  const newDone = !currentDone;
  const completedAt = newDone ? new Date().toISOString() : null;

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const { error } = await (supabase.from("user_squares") as any)
    .update({ is_done: newDone, completed_at: completedAt })
    .eq("user_id", user.id)
    .eq("square_id", squareId);

  if (error) throw new Error(error.message);

  revalidatePath("/");
  revalidatePath("/leaderboard");
}

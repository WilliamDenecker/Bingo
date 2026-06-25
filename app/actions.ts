"use server";

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";

export async function uploadAvatar(formData: FormData) {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) throw new Error("Not authenticated");

  const file = formData.get("avatar") as File | null;
  if (!file || file.size === 0) throw new Error("No file provided");
  if (file.size > 2 * 1024 * 1024) throw new Error("File must be under 2 MB");

  const ext = file.name.split(".").pop()?.toLowerCase() ?? "jpg";
  const path = `${user.id}/avatar.${ext}`;
  const bytes = await file.arrayBuffer();

  const { error: uploadError } = await supabase.storage
    .from("avatars")
    .upload(path, bytes, { contentType: file.type, upsert: true });

  if (uploadError) throw new Error(uploadError.message);

  const { data: urlData } = supabase.storage.from("avatars").getPublicUrl(path);
  const publicUrl = `${urlData.publicUrl}?t=${Date.now()}`;

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const { error: updateError } = await (supabase.from("profiles") as any)
    .update({ avatar_url: publicUrl })
    .eq("id", user.id);

  if (updateError) throw new Error(updateError.message);

  revalidatePath("/profile");
  revalidatePath("/leaderboard");
}

export async function toggleSquare(squareId: number, currentDone: boolean, proofUrl?: string) {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) throw new Error("Not authenticated");

  const newDone = !currentDone;
  const completedAt = newDone ? new Date().toISOString() : null;

  // When unchecking, delete the proof file from storage if one exists
  if (!newDone) {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const { data: existing } = await (supabase.from("user_squares") as any)
      .select("proof_url")
      .eq("user_id", user.id)
      .eq("square_id", squareId)
      .single();

    if (existing?.proof_url) {
      // Extract the storage path from the public URL: everything after "/proofs/"
      const match = (existing.proof_url as string).match(/\/proofs\/(.+?)(\?|$)/);
      if (match) {
        await supabase.storage.from("proofs").remove([decodeURIComponent(match[1])]);
      }
    }
  }

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const { error } = await (supabase.from("user_squares") as any)
    .update({
      is_done: newDone,
      completed_at: completedAt,
      proof_url: newDone ? (proofUrl ?? null) : null,
    })
    .eq("user_id", user.id)
    .eq("square_id", squareId);

  if (error) throw new Error(error.message);

  revalidatePath("/");
  revalidatePath("/leaderboard");
  revalidatePath("/feed");
}


"use client";

import { useRef, useState, useTransition } from "react";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { uploadAvatar } from "@/app/actions";
import { Camera } from "lucide-react";

interface Props {
  displayName: string;
  avatarUrl: string | null;
}

export function AvatarUpload({ displayName, avatarUrl }: Props) {
  const [preview, setPreview] = useState<string | null>(avatarUrl);
  const [error, setError] = useState<string | null>(null);
  const [isPending, startTransition] = useTransition();
  const inputRef = useRef<HTMLInputElement>(null);

  function handleChange(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;

    setPreview(URL.createObjectURL(file));
    setError(null);

    const formData = new FormData();
    formData.append("avatar", file);

    startTransition(async () => {
      try {
        await uploadAvatar(formData);
      } catch (err) {
        setError(err instanceof Error ? err.message : "Upload failed");
      }
    });
  }

  return (
    <div className="flex flex-col items-center gap-3 py-4">
      <button
        type="button"
        onClick={() => inputRef.current?.click()}
        className="relative group cursor-pointer"
        disabled={isPending}
        aria-label="Change profile picture"
      >
        <Avatar className="h-20 w-20">
          {preview && <AvatarImage src={preview} alt={displayName} />}
          <AvatarFallback className="text-2xl font-bold">
            {displayName.slice(0, 2).toUpperCase()}
          </AvatarFallback>
        </Avatar>
        <span className="absolute inset-0 flex items-center justify-center rounded-full bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity">
          <Camera className="h-6 w-6 text-white" />
        </span>
        {isPending && (
          <span className="absolute inset-0 flex items-center justify-center rounded-full bg-black/50">
            <span className="h-5 w-5 rounded-full border-2 border-white border-t-transparent animate-spin" />
          </span>
        )}
      </button>
      <input
        ref={inputRef}
        type="file"
        accept="image/*"
        className="hidden"
        onChange={handleChange}
      />
      {error && <p className="text-xs text-destructive">{error}</p>}
    </div>
  );
}

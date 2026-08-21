import { apiClient } from "@/lib/http/client";

export type ChansonCreateRequest = {
  titre: string;
  duree?: number;
  description?: string;
  genre?: string;
  prix?: number;
  albumId?: number;
  categorieId?: number;
  artisteId?: number;
  tags?: string[];
  isPublic?: boolean;
  parole?: string;
};

function appendJsonField(formData: FormData, fieldName: string, value: unknown) {
  formData.append(
    fieldName,
    new Blob([JSON.stringify(value)], { type: "application/json" }),
  );
}

export async function publierChanson(
  chansonCreateRequest: ChansonCreateRequest,
  audioFile: File,
  coverFile?: File | null,
): Promise<unknown> {
  const formData = new FormData();

  appendJsonField(formData, "data", chansonCreateRequest);
  formData.append("file", audioFile, audioFile.name);
  if (coverFile) {
    formData.append("cover", coverFile, coverFile.name);
  }

  return apiClient.post("/chansons/publier", formData);
}

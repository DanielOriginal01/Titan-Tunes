export function getAuthToken() {
  if (typeof window === "undefined") return null;
  return window.localStorage.getItem("titan-tunes-token");
}

export function isAuthenticated() {
  return Boolean(getAuthToken());
}

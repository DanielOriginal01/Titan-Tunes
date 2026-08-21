import { useEffect, useState } from "react";

type FetchState<T> = {
  data: T | null;
  error: Error | null;
  loading: boolean;
};

export function useFetch<T>(url: string) {
  const [state, setState] = useState<FetchState<T>>({ data: null, error: null, loading: true });

  useEffect(() => {
    let isMounted = true;

    fetch(url)
      .then((res) => res.json())
      .then((data) => {
        if (isMounted) setState({ data, error: null, loading: false });
      })
      .catch((error) => {
        if (isMounted) setState({ data: null, error, loading: false });
      });

    return () => {
      isMounted = false;
    };
  }, [url]);

  return state;
}

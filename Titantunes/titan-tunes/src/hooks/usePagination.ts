import { useMemo, useState } from "react";

export function usePagination(totalItems: number, initialPage = 1, pageSize = 10) {
  const [page, setPage] = useState(initialPage);
  const pageCount = useMemo(() => Math.ceil(totalItems / pageSize), [totalItems, pageSize]);

  return {
    page,
    pageSize,
    pageCount,
    setPage,
    startIndex: (page - 1) * pageSize,
    endIndex: Math.min(page * pageSize, totalItems),
  };
}

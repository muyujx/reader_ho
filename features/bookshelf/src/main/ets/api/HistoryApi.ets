import { requestPost, ReadingHistoryItem } from '@ohos/common';

interface HistoryListBody {
  startStr: string;
  endStr: string;
}

export function listReadingHistory(startStr: string, endStr: string): Promise<ReadingHistoryItem[]> {
  const body: HistoryListBody = {
    startStr: startStr,
    endStr: endStr
  };
  return requestPost<ReadingHistoryItem[]>({
    url: '/api/read/history/list',
    body: body
  });
}

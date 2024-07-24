
## 캐싱 처리 로직 구현

### 1.사용 라이브러리
- RxSwift


### 캐시 처리
   - Memory Cache, Disk Cache 모두 사용
   - 두 캐시 중에 모두 없을 경우만 이미지 데이터를 다운로드 하였습니다.
   - 다운로드 후 Memory Cache, Disk Cache에 적재 하였습니다.
   - Cell에서 사용할 때
         if let memory = memoryCache(item: item) {
            return .just(memory)
        }
        else if let disk = diskMemoryCache(item: item) {
            return .just(disk)
        }
        else {
            return getCacheData(item: item)
        }

     Memory Cache순부터 DiskCache순으로 탐색하여 없을 경우에 해당 URL을 다운로드 하여 data를 반환 했습니다.


### PS. 프로젝트 생성하기 위해서는 terminal에서 tuist generate 입력해야 합니다.

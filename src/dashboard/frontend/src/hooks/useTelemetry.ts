// React에서 제공하는 Hook
import { useEffect, useRef, useState } from "react";
// socket.io-client 라이브러리 import
import { io, Socket } from "socket.io-client";
// Telemetry 타입 정의 import
import type { Telemetry } from "../lib/telemetry";


/**
 * useTelemetry Hook
 * - 서버에서 실시간 차량 데이터(telemetry)를 받아오는 커스텀 훅
 * - socket.io를 사용하여 WebSocket 연결을 유지하며 상태를 갱신
 */
export default function useTelemetry() {
  // t: 현재 telemetry 데이터 상태
  // setT: 상태 변경 함수
  // 초기값: { rpm: 0, speed: 0, battery: 0 }
  const [t, setT] = useState<Telemetry>({ rpm: 0, speed: 0, battery: 100 ,gear : "P"});

  // sock: 현재 소켓 연결 객체를 저장하는 ref
  // - useRef 사용 이유: 컴포넌트 리렌더링 시에도 소켓 인스턴스를 유지
  const sock = useRef<Socket | null>(null);

  // 컴포넌트 마운트 시 1회 실행
  useEffect(() => {
    // 1) socket.io 서버에 연결
    //    - "/" : 같은 도메인의 기본 주소
    //    - path: 서버에서 설정한 socket.io 경로
    //    - transports: WebSocket 방식 우선 사용
    //    - reconnection: 연결 끊겼을 때 자동 재연결
    const s = io("/", {
      path: "/socket.io",
      transports: ["websocket"],
      reconnection: true,
    });

    // 소켓 객체를 ref에 저장
    sock.current = s;

    // 2) 서버로부터 "telemetry" 이벤트 수신 시 상태 갱신
    //    payload: Telemetry 타입 데이터 ({ rpm, speed, battery })
    s.on("telemetry", (payload: Telemetry) => setT(payload));

    // 3) 연결 오류 이벤트 처리
    s.on("connect_error", (e) => console.warn("[socket] error", e.message));

    // 4) 컴포넌트 언마운트 시 소켓 연결 종료
    return () => {
      s.close();
    };
  }, []); // 빈 배열 → 컴포넌트 처음 마운트될 때만 실행

  // 현재 telemetry 상태 반환
  return t;
}

/*
유지보수 참고:
- Telemetry 타입 변경 시 초기값과 setT(payload) 부분도 함께 수정해야 함
- 서버 측 socket.io 경로(path)와 이벤트명("telemetry")이 변경되면 이 훅도 수정 필요
- reconnection 옵션을 true로 두면 네트워크 단절 후 자동 재연결 가능
- 개발 중 서버 주소가 다르면 io("http://서버주소:포트") 형식으로 변경해야 함
*/

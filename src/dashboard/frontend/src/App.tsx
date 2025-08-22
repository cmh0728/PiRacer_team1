import { useEffect, useRef, useState } from "react";
import useTelemetry from "./hooks/useTelemetry";

function mapToAngle(val: number, max: number) {
  const clamped = Math.max(0, Math.min(max, val));
  return -90 + (clamped / max) * 180;
}

// ---- WebRTC helper (브라우저 ← 서버 단방향 수신, UDP 기반) ----
async function startWebRTC(videoEl: HTMLVideoElement) {
  const pc = new RTCPeerConnection({
    iceServers: [{ urls: "stun:stun.l.google.com:19302" }],
  });

  // 서버 → 브라우저 단방향
  pc.addTransceiver("video", { direction: "recvonly" });

  pc.ontrack = (e) => {
    videoEl.srcObject = e.streams[0];
  };

  const offer = await pc.createOffer();
  await pc.setLocalDescription(offer);

  const res = await fetch("/rtc/offer", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      sdp: pc.localDescription!.sdp,
      type: pc.localDescription!.type,
    }),
  });

  if (!res.ok) {
    throw new Error(await res.text());
  }

  const answer = await res.json();
  await pc.setRemoteDescription(answer);
  return pc;
}

// 브라우저 상태 → 우리 UI 상태로 정규화
type UiConn = "idle" | "connecting" | "connected" | "failed";
function deriveConnState(pc: RTCPeerConnection): UiConn {
  const s =
    (pc.connectionState ||
      (pc as any).iceConnectionState) as
      | RTCPeerConnectionState
      | RTCIceConnectionState
      | undefined;

  switch (s) {
    // 연결됨
    case "connected":
    case "completed":
      return "connected";
    // 연결 중
    case "connecting":
    case "checking":
    case "new":
      return "connecting";
    // 실패/끊김/종료
    case "failed":
    case "disconnected":
    case "closed":
      return "failed";
    default:
      return "idle";
  }
}

export default function App() {
  const t = useTelemetry();
  const cms = t.speed || 0;

  // 🔑 모달/비밀번호 상태
  const [showModal, setShowModal] = useState(false);
  const [password, setPassword] = useState("");

  // WebRTC 상태
  const videoRef = useRef<HTMLVideoElement>(null);
  const pcRef = useRef<RTCPeerConnection | null>(null);
  const [connState, setConnState] = useState<UiConn>("idle");
  const [errMsg, setErrMsg] = useState<string | null>(null);

  // 최초 연결 시도
  useEffect(() => {
    let mounted = true;

    (async () => {
      try {
        setConnState("connecting");
        setErrMsg(null);
        if (!videoRef.current) return;

        const pc = await startWebRTC(videoRef.current);
        if (!mounted) {
          pc.close();
          return;
        }
        pcRef.current = pc;

        const update = () => setConnState(deriveConnState(pc));
        pc.onconnectionstatechange = update;
        pc.oniceconnectionstatechange = update;

        // 초기 상태 반영
        update();
      } catch (e: any) {
        setConnState("failed");
        setErrMsg(e?.message ?? String(e));
      }
    })();

    return () => {
      mounted = false;
      if (pcRef.current) {
        pcRef.current.close();
        pcRef.current = null;
      }
      if (videoRef.current) {
        (videoRef.current as HTMLVideoElement).srcObject = null;
      }
    };
  }, []);

  const reconnect = async () => {
    try {
      // 기존 연결 정리
      if (pcRef.current) {
        pcRef.current.close();
        pcRef.current = null;
      }
      if (videoRef.current) {
        (videoRef.current as HTMLVideoElement).srcObject = null;
      }

      setConnState("connecting");
      setErrMsg(null);

      const pc = await startWebRTC(videoRef.current!);
      pcRef.current = pc;

      const update = () => setConnState(deriveConnState(pc));
      pc.onconnectionstatechange = update;
      pc.oniceconnectionstatechange = update;
      update();
    } catch (e: any) {
      setConnState("failed");
      setErrMsg(e?.message ?? String(e));
    }
  };

  // 🔑 리셋 동작
  const handleReset = async () => {
    const res = await fetch("/api/reset", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ password }),
    });

    if (res.ok) {
      alert("Rebooting...");
    } else {
      alert("Wrong password!");
    }
    setShowModal(false);
    setPassword("");
  };

  return (
    <div className="min-h-dvh grid place-items-center bg-gray text-slate-900">
      {/* 16:9 보드 */}
      <div className="relative w-[min(100vw,177.78vh)] aspect-[19/10] rounded-3xl border bg-neutral-900 shadow">
        <div className="absolute inset-0 p-[2%] grid grid-rows-[auto_60%_1fr] gap-[2%]">
          {/* 팀 배지 + 연결 상태 */}
          <div className="flex items-center justify-between">
            <span className="inline-flex items-center rounded-xl px-3 py-1 text-[max(30px,1.4vmin)] text-white font-semibold bg-neutral-800">
              Team1 Dashboard
            </span>
            <span
              className={`inline-flex items-center gap-2 rounded-xl px-3 py-1 text-sm ${
                connState === "connected"
                  ? "bg-emerald-600 text-white"
                  : connState === "connecting"
                  ? "bg-amber-600 text-white"
                  : "bg-red-600 text-white"
              }`}
            >
              <span
                className={`w-2 h-2 rounded-full ${
                  connState === "connected"
                    ? "bg-emerald-300"
                    : connState === "connecting"
                    ? "bg-amber-300"
                    : "bg-red-300"
                }`}
              />
              {connState === "connected"
                ? "WebRTC Connected (UDP)"
                : connState === "connecting"
                ? "Connecting…"
                : "Disconnected"}
            </span>
          </div>

          {/* 상단 3분할: RPM / Camera / Speed */}
          <div className="grid grid-cols-3 gap-[2%]">
            {/* RPM Gauge */}
            <div className="flex items-center justify-center rounded-2xl bg-neutral-800 border shadow-sm">
              <div className="p-4 w-full">
                <div className="text-sm text-neutral-400">RPM</div>
                <svg viewBox="0 0 200 120" className="w-full mt-2">
                  <path
                    d="M10 110 A90 90 0 0 1 190 110"
                    fill="none"
                    stroke="#333"
                    strokeWidth="12"
                  />
                  <line
                    x1="100"
                    y1="110"
                    x2="100"
                    y2="30"
                    stroke="white"
                    strokeWidth="4"
                    strokeLinecap="round"
                    transform={`rotate(${mapToAngle(t.rpm || 0, 500)} 100 110)`}
                  />
                </svg>
                <div className="text-center text-xl font-bold mt-1">
                  {t.rpm} RPM
                </div>
              </div>
            </div>

            {/* 카메라 스트림 (WebRTC only, UDP) */}
            <div className="relative rounded-2xl border overflow-hidden bg-neutral-800">
              <video
                ref={videoRef}
                autoPlay
                playsInline
                muted
                className="w-full h-full object-cover"
              />
              {connState === "failed" && (
                <div className="absolute inset-0 grid place-items-center bg-neutral-900/70">
                  <div className="text-center">
                    <div className="text-white font-semibold mb-2">
                      WebRTC 연결 실패
                    </div>
                    {errMsg && (
                      <div className="text-xs text-neutral-300 mb-3">
                        {errMsg}
                      </div>
                    )}
                    <button
                      onClick={reconnect}
                      className="px-4 py-2 rounded bg-gray-800 hover:bg-gray-900 text-white"
                    >
                      Reconnect
                    </button>
                  </div>
                </div>
              )}
            </div>

            {/* Speed Gauge */}
            <div className="flex items-center justify-center rounded-2xl bg-neutral-800 border shadow-sm">
              <div className="p-4 w-full">
                <div className="text-sm text-neutral-400">Speed</div>
                <svg viewBox="0 0 200 120" className="w-full mt-2">
                  <path
                    d="M10 110 A90 90 0 0 1 190 110"
                    fill="none"
                    stroke="#333"
                    strokeWidth="12"
                  />
                  <line
                    x1="100"
                    y1="110"
                    x2="100"
                    y2="30"
                    stroke="white"
                    strokeWidth="4"
                    strokeLinecap="round"
                    transform={`rotate(${mapToAngle(cms, 120)} 100 110)`}
                  />
                </svg>
                <div className="text-center text-xl font-bold mt-1">
                  {cms} cm/s
                </div>
              </div>
            </div>
          </div>

          {/* 하단 보드 상태 */}
          <div className="grid grid-cols-5 gap-[2%]">
            {/* CPU Usage */}
            <div className="p-4 rounded-2xl border bg-neutral-800 shadow-sm">
              <div className="text-sm text-neutral-400 mb-2">CPU Usage</div>
              <div className="w-full bg-neutral-700 rounded-full h-3 overflow-hidden">
                <div
                  className="h-3 transition-all duration-300 bg-indigo-500"
                  style={{ width: `${t.cpu ?? 0}%` }}
                />
              </div>
              <div className="text-sm text-neutral-300 mt-1">
                {t.cpu ?? 0} %
              </div>
            </div>

            {/* 배터리 */}
            <div className="p-4 rounded-2xl border bg-neutral-800 shadow-sm">
              <div className="text-sm text-neutral-400 mb-2">Battery</div>
              <div className="w-full bg-neutral-700 rounded-full h-3 overflow-hidden">
                <div
                  className="h-3 transition-all duration-300 bg-emerald-500"
                  style={{ width: `${t.battery}%` }}
                />
              </div>
              <div className="text-sm text-neutral-300 mt-1">
                {t.battery} %
              </div>
            </div>

            {/* 네트워크 상태 */}
            <div className="p-4 rounded-2xl border bg-neutral-800 shadow-sm flex flex-col items-center justify-center">
              <div className="text-sm text-neutral-400 mb-2">Network</div>
              <div
                className={`w-3 h-3 rounded-full ${
                  t.net ? "bg-green-500" : "bg-red-500"
                }`}
              />
              <span className="text-sm mt-1 text-neutral-300">
                {t.net ? "Connected" : "Offline"}
              </span>
            </div>

            {/* Gear */}
            <div className="p-4 rounded-2xl border bg-neutral-800 shadow-sm">
              <div className="text-sm text-neutral-400">Gear</div>
              <div className="text-4xl font-bold mt-1">{t.gear}</div>
            </div>

            {/* 리셋 버튼 */}
            <button
              onClick={() => setShowModal(true)}
              type="button"
              className="text-white bg-gray-800 hover:bg-gray-900 focus:outline-none focus:ring-4 focus:ring-gray-300 font-medium rounded-lg text-sm px-5 py-2.5 me-2 mb-2"
            >
              Reboot
            </button>
          </div>
        </div>
      </div>

      {/* 비밀번호 입력 창 모달*/}
      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-60 flex items-center justify-center">
          <div className="bg-neutral-800 p-6 rounded-2xl shadow-lg">
            <h2 className="text-white font-bold mb-3">Enter Password</h2>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full p-2 rounded bg-neutral-700 text-white"
              placeholder="Password"
            />
            <div className="flex justify-end mt-4 gap-2">
              <button
                onClick={() => setShowModal(false)}
                type="button"
                className="text-white bg-gray-800 hover:bg-gray-900 focus:outline-none focus:ring-4 focus:ring-gray-300 font-medium rounded-lg text-sm px-5 py-2.5"
              >
                Cancel
              </button>
              <button
                onClick={handleReset}
                type="button"
                className="text-white bg-gray-800 hover:bg-gray-900 focus:outline-none focus:ring-4 focus:ring-gray-300 font-medium rounded-lg text-sm px-5 py-2.5"
              >
                Confirm
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

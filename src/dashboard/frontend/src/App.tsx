import { useState } from "react";
import useTelemetry from "./hooks/useTelemetry";

// function gearLabel(g: unknown): string {
//   if (g === undefined || g === null) return "N";
//   const s = String(g).toUpperCase();
//   const map: Record<string, string> = { "0":"N", "1":"D", "2":"R", "3":"P", "N":"N", "D":"D", "R":"R", "P":"P" };
//   return map[s] ?? s;
// }


function mapToAngle(val: number, max: number) {
  const clamped = Math.max(0, Math.min(max, val));
  return -90 + (clamped / max) * 180;
}

export default function App() {
  const t = useTelemetry();
  const cms = t.speed || 0;

  // 🔑 모달/비밀번호 상태
  const [showModal, setShowModal] = useState(false);
  const [password, setPassword] = useState("");

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
          {/* 팀 배지 */}
          <div>
            <span className="inline-flex items-center rounded-xl px-3 py-1 text-[max(30px,1.4vmin)] text-white font-semibold bg-neutral-800">
              Team1 Dashboard
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

            {/* 카메라 스트림 (TCP MJPEG) */}
            <div className="relative rounded-2xl border overflow-hidden bg-neutral-800">
              <img
                id="video"
                src="/video_feed"
                alt="camera"
                className="w-full h-full object-cover"
              />
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
            <div className="p-4 rounded-2xl border bg-neutral-800 shadow-sm flex flex-col items-center justify-center">
            <div className="text-sm text-neutral-400 mb-2">CPU Usage</div>
            <div className="w-3/4 bg-neutral-700 rounded-full h-3 overflow-hidden">
              <div
                className="bg-indigo-500 h-3 transition-all duration-300"
                style={{ width: `${t.cpu ?? 0}%` }}
              />
            </div>
            <div className="text-sm text-neutral-300 mt-1">{t.cpu ?? 0} %</div>
          </div>



            {/* Battery */}
            <div className="p-4 rounded-2xl border bg-neutral-800 shadow-sm flex flex-col items-center justify-center">
            <div className="text-sm text-neutral-400 mb-2">Battery</div>
            <div className="w-3/4 bg-neutral-700 rounded-full h-3 overflow-hidden">
              <div
                className="bg-emerald-500 h-3 transition-all duration-300"
                style={{ width: `${t.battery}%` }}
              />
            </div>
            <div className="text-sm text-neutral-300 mt-1">{t.battery} %</div>
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
            <div className="p-4 rounded-2xl border bg-neutral-800 shadow-sm flex flex-col items-center justify-center">
            <div className="text-sm text-neutral-400">Gear</div>
            <div className="mt-2 text-4xl font-bold text-neutral-100">
              {t.gear ?? "N"}
            </div>
          </div>


            {/* 리셋 버튼 */}
            <button
              onClick={() => setShowModal(true)}
              type="button"
              className="text-white bg-neutral-800 hover:bg-neutral-900 focus:outline-none focus:ring-4 focus:ring-neutral-300 font-medium rounded-lg text-sm px-5 py-2.5"
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
            <h2 className="text-black font-bold mb-3">Enter Password</h2>
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
                className="text-black bg-gray-800 hover:bg-gray-900 focus:outline-none focus:ring-4 focus:ring-gray-300 font-medium rounded-lg text-sm px-5 py-2.5 me-2 mb-2 dark:bg-gray-800 dark:hover:bg-gray-700 dark:focus:ring-gray-700 dark:border-gray-700"
              >
                Cancel
              </button>

              <button
                onClick={handleReset}
                type="button"
                className="text-black bg-gray-800 hover:bg-gray-900 focus:outline-none focus:ring-4 focus:ring-gray-300 font-medium rounded-lg text-sm px-5 py-2.5 me-2 mb-2 dark:bg-gray-800 dark:hover:bg-gray-700 dark:focus:ring-gray-700 dark:border-gray-700"
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

// src/App.tsx
import useTelemetry from "./hooks/useTelemetry";

function mapToAngle(val: number, max: number) {
  const clamped = Math.max(0, Math.min(max, val));
  return -90 + (clamped / max) * 180;
}

// function gearToLabel(g: string | number) {
//   if (typeof g === "string") return g;
//   return ({ 0: "N", 1: "D", 2: "R", 3: "P" } as Record<number, string>)[g] ?? "N";
// }

export default function App() {
  const t = useTelemetry();
  const kmh = Math.round((t.speed || 0) * 0.036);

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
            
            {/* RPM Gauge (반원 게이지 + 바늘) */}
            <div className="flex items-center justify-center rounded-2xl bg-neutral-800 border shadow-sm">
              <div className="p-4 w-full">
                <div className="text-sm text-neutral-400">RPM</div>
                <svg viewBox="0 0 200 120" className="w-full mt-2">
                  {/* 반원 게이지 배경 */}
                  <path
                    d="M10 110 A90 90 0 0 1 190 110"
                    fill="none"
                    stroke="#333"
                    strokeWidth="12"
                  />
                  {/* 바늘 */}
                  <line
                    x1="100"
                    y1="110"
                    x2="100"
                    y2="30"
                    stroke="white"
                    strokeWidth="4"
                    strokeLinecap="round"
                    transform={`rotate(${mapToAngle(t.rpm || 0, 7000)} 100 110)`}
                  />
                </svg>
                <div className="text-center text-xl font-bold mt-1">
                  {t.rpm} RPM
                </div>
              </div>
            </div>

            {/* 카메라 스트림 */}
            <div className="relative rounded-2xl border overflow-hidden bg-neutral-800">
              <img
                id="video"
                src="/video_feed"
                alt="camera"
                className="w-full h-full object-cover"
              />
            </div>

            {/* Speed Gauge (반원 게이지 + 바늘) */}
            <div className="flex items-center justify-center rounded-2xl bg-neutral-800 border shadow-sm">
              <div className="p-4 w-full">
                <div className="text-sm text-neutral-400">Speed</div>
                <svg viewBox="0 0 200 120" className="w-full mt-2">
                  {/* 반원 게이지 배경 */}
                  <path
                    d="M10 110 A90 90 0 0 1 190 110"
                    fill="none"
                    stroke="#333"
                    strokeWidth="12"
                  />
                  {/* 바늘 */}
                  <line
                    x1="100"
                    y1="110"
                    x2="100"
                    y2="30"
                    stroke="white"
                    strokeWidth="4"
                    strokeLinecap="round"
                    transform={`rotate(${mapToAngle(kmh, 120)} 100 110)`}
                  />
                </svg>
                <div className="text-center text-xl font-bold mt-1">
                  {kmh} km/h
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
                  className="bg-indigo-500 h-3 transition-all duration-300"
                  style={{ width: `${t.cpu ?? 0}%` }}
                ></div>
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
                  className="bg-emerald-500 h-3 transition-all duration-300"
                  style={{ width: `${t.battery}%` }}
                ></div>
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
            <button className="p-4 rounded-2xl bg-red-600 hover:bg-red-700 shadow-lg font-bold text-white text-lg">
              RESET
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

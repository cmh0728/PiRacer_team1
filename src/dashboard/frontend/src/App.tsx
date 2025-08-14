// src/App.tsx
import Card from "./components/Card";
import useTelemetry from "./hooks/useTelemetry";

export default function App() {
  const t = useTelemetry();

  return (
    // 화면 중앙 배치
    <div className="min-h-dvh grid place-items-center bg-gray text-slate-900">
      {/* 16:9 비율 보드: 뷰포트에 맞춰 자동 스케일 */}
      <div className="relative w-[min(100vw,177.78vh)] aspect-[21/12] rounded-3xl border bg-neutral-900 shadow">
        {/* 내부는 퍼센트 단위로 → 비율 유지 */}
        {/* 내부 레이아웃: 배지 / 카메라 / 배지 / 하단 카드 */}
        <div className="absolute inset-0 p-[2%] grid grid-rows-[auto_60%_auto_1fr] gap-[2%]">
          
          {/* 팀 배지 */}
          <div>
            <span className="inline-flex items-center rounded-xl px-3 py-1 text-[max(30px,1.4vmin)] text-white font-semibold bg-neutral-800">
              Team1 Dashboard
            </span>
          </div>

          {/* 카메라 */}
          <div className="relative rounded-2xl border overflow-hidden bg-neutral-800">
            <img
              id="video"
              src="/video_feed"
              alt="camera"
              className="w-full h-full object-cover"
            />
          </div>

          <div>
            <span className="inline-flex items-center rounded-xl px-3 py-1 text-[max(20px,1.4vmin)] text-white font-semibold bg-neutral-800">
              PiRacer Status
            </span>
          </div>

          {/* 하단 카드 */}
          <div className="grid grid-cols-4 gap-[2%]">
            <Card title="RPM" value={Math.round(t.rpm)} />
            <Card title="Speed" value={typeof t.speed === "number" ? t.speed.toFixed(1) : "0.0"}  unit="[cm/s]" />
            {/* 배터리 바 */}
            <div className="p-4 rounded-2xl border bg-neutral-800 shadow-sm">
              <div className="text-sm text-neutral-400 mb-2 text-[max(20px,1.4vmin)]">Battery</div>
              <div className="w-full bg-neutral-700 rounded-full h-3 overflow-hidden">
                <div className="bg-emerald-500 h-3 transition-all duration-300 "
                  style={{ width: `${t.battery}%` }}
                ></div>
              </div>
              <div className="flex-1 flex text-sm text-neutral-300 mt-1 text-[max(15px,1.4vmin)]">{t.battery} %</div>
            </div>
            <Card title="Gear" value={t.gear}/>
          </div>
        </div>
      </div>
    </div>
  );
}

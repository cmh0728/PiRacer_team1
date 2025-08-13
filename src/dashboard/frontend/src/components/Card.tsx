// src/components/Card.tsx

// Card 컴포넌트의 props 타입 정의
// - title: 카드 상단에 표시될 제목(문자열)
// - value: 카드에 표시할 값 (문자열 또는 숫자 가능)
// - unit: 값의 단위 (선택적, 없을 수도 있음)
type CardProps = { title: string; value: string | number; unit?: string };

export default function Card({ title, value, unit }: CardProps) {
  return (
    // 카드 컨테이너
    // - 배경색: 그레이 900(bg-gray-900)
    // - 테두리: 흰색(border-white)
    // - 모서리: 둥글게 처리(rounded-2xl)
    // - 내부 여백: 부모 크기의 2%(p-[2%])
    // - 그림자 효과: 작게(shadow-sm)
    <div className="relative rounded-2xl border bg-neutral-800 p-[2%] shadow-sm flex flex-col">
      
      {/* 제목 영역 */}
      {/* - 약간의 투명도(opacity-70)로 강조를 줄임 */}
      {/* - 화면 크기에 따라 자동 조정되는 반응형 폰트 크기 */}
      <div className="absolute top-[5%] left-[5%] text-[max(30px,1.4vmin)] opacity-80 text-white text-left">
        {title}
      </div>
      
      {/* 값(value) 영역 */}
      {/* - 볼드 처리(font-semibold)로 강조 */}
      {/* - tracking-tight: 글자 간격을 좁혀서 시각적으로 안정감 부여 */}
      {/* - 반응형 폰트 크기 적용 */}
      <div className="flex-1 flex items-center justify-center mt-[1%] font-semibold tracking-tight text-[max(30px,4vmin)] text-white text-center">
        {value}
        
        {/* 단위(unit) 표시 */}
        {/* - unit 값이 존재할 때만 렌더링 */}
        {/* - 값보다 약간 작은 폰트 크기와 낮은 투명도로 시각적 구분 */}
        {unit && (
          <span className="ml-[5%] text-[max(25px,1.6vmin)] opacity-80 text-white">
            {unit}
          </span>
        )}
      </div>
    </div>
  );
}

// 유지보수 참고:
// - 이 Card 컴포넌트는 항상 검정 배경 + 흰 글자를 사용합니다.
// - 밝은 배경 테마를 지원하려면 text 색상과 bg 색상을 props로 받아서 조건부로 설정하는 구조로 변경하는 것을 고려하세요.
// - Tailwind CSS 클래스 변경 시 디자인 시스템(폰트 크기, 여백 비율)을 유지하면 전체 대시보드 스타일이 통일됩니다.

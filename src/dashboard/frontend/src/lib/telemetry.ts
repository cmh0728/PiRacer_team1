export type Telemetry = {
  rpm: number;
  speed: number;   // cm/s
  battery: number; // 0~100 %
  gear : string; // 3 : p, 1 : D , 0 : N , 2 : R 
  
};

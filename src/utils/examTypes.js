// 驾考车型枚举定义
export const ExamTypes = {
  // 小车类
  C1: {
    code: 'C1',
    name: 'C1 小型汽车',
    description: '小型、微型载客汽车以及轻型、微型载货汽车',
    subject1Count: 100,
    subject4Count: 50,
  },
  C2: {
    code: 'C2',
    name: 'C2 小型自动挡汽车',
    description: '小型、微型自动挡载客汽车以及轻型、微型自动挡载货汽车',
    subject1Count: 100,
    subject4Count: 50,
  },
  /*C3: {
    code: 'C3',
    name: 'C3 低速载货汽车',
    description: '低速载货汽车（原四轮农用运输车）',
    subject1Count: 100,
    subject4Count: 50,
  },
  C4: {
    code: 'C4',
    name: 'C4 三轮汽车',
    description: '三轮汽车（原三轮农用运输车）',
    subject1Count: 100,
    subject4Count: 50,
  },*/

  // 客车类
  A1: {
    code: 'A1',
    name: 'A1 大型客车',
    description: '大型载客汽车',
    subject1Count: 100,
    subject4Count: 50,
  },
  /*A3: {
    code: 'A3',
    name: 'A3 城市公交车',
    description: '核载10人以上的城市公共汽车',
    subject1Count: 100,
    subject4Count: 50,
  },*/
  B1: {
    code: 'B1',
    name: 'B1 中型客车',
    description: '中型载客汽车（含核载10人以上、19人以下的城市公共汽车）',
    subject1Count: 100,
    subject4Count: 50,
  },

  // 货车类
  A2: {
    code: 'A2',
    name: 'A2 牵引车',
    description: '重型、中型全挂、半挂汽车列车',
    subject1Count: 100,
    subject4Count: 50,
  },
  B2: {
    code: 'B2',
    name: 'B2 大型货车',
    description: '重型、中型载货汽车；大、重、中型专项作业车',
    subject1Count: 100,
    subject4Count: 50,
  },

  // 摩托车类
  /*D: {
    code: 'D',
    name: 'D 普通三轮摩托车',
    description: '发动机排量大于50ml或者最大设计车速大于50km/h的三轮摩托车',
    subject1Count: 100,
    subject4Count: 50,
  },
  E: {
    code: 'E',
    name: 'E 普通二轮摩托车',
    description: '发动机排量大于50ml或者最大设计车速大于50km/h的二轮摩托车',
    subject1Count: 100,
    subject4Count: 50,
  },
  F: {
    code: 'F',
    name: 'F 轻便摩托车',
    description: '发动机排量小于等于50ml，最大设计车速小于等于50km/h的摩托车',
    subject1Count: 100,
    subject4Count: 50,
  },*/

  // 其他类
  /*C6: {
    code: 'C6',
    name: 'C6 轻型牵引挂车',
    description: '总质量小于4500kg的汽车列车',
    subject1Count: 100,
    subject4Count: 50,
  },*/
}

// 按类别分组
export const ExamTypeGroups = {
  car: {
    name: '小车类',
    types: [ExamTypes.C1, ExamTypes.C2],
    // types: [ExamTypes.C1, ExamTypes.C2, ExamTypes.C3, ExamTypes.C4],
  },
  bus: {
    name: '客车类',
    types: [ExamTypes.A1, ExamTypes.B1],
    // types: [ExamTypes.A1, ExamTypes.A3, ExamTypes.B1],
  },
  truck: {
    name: '货车类',
    types: [ExamTypes.A2, ExamTypes.B2],
  },
  /*motorcycle: {
    name: '摩托车类',
    types: [ExamTypes.D, ExamTypes.E, ExamTypes.F],
  },*/
  /*other: {
    name: '其他类',
    types: [ExamTypes.C6],
  },*/
}

// 获取所有车型
export const getAllExamTypes = () => {
  return Object.values(ExamTypes)
}

// 根据code获取车型信息
export const getExamTypeByCode = (code) => {
  return ExamTypes[code] || null
}

// 获取默认车型（C1）
export const getDefaultExamType = () => {
  return ExamTypes.C1
}

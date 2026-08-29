ServerEvents.recipes(event => {

event.custom({
    type: "farmersdelight:cutting",
  ingredients: [
    {
      item: "minecraft:bread"
    }
  ],
  result: [
    {
      item: {
        count: 4,
        id: "kevdelights:bread_slice"
      }
    }
  ],
  sound: {
    sound_id: "create:clipboard_check"
  },
  tool: [
    {
      type: "farmersdelight:item_ability",
      action: "knife_dig"
    },
    {
      tag: "c:tools/knife"
    }
  ]
  });

event.custom({
    type: "create:cutting",
  ingredients: [
    {
      item: "minecraft:bread"
    }
  ],
  processing_time: 200,
  results: [
    {
      count: 4,
      id: "kevdelights:bread_slice"
    }
  ]
  });

event.custom({
  type: "minecraft:smoking",
  category: "food",
  cookingtime: 100,
  experience: 0.0,
  ingredient: {
    item: "kevdelights:bread_slice"
  },
  result: {
    count: 1,
    id: "kevdelights:toasted_bread_slice"
  }
});

event.custom({
  type: "create:mixing",
  heat_requirement: "heated",
  ingredients: [
    {
      item: "minecraft:sweet_berries"
    },
    {
      item: "minecraft:sugar"
    }
  ],
  results: [
    {
      id: "kevdelights:jam_spread"
    }
  ]
});

event.custom({
  type: "create:mixing",
  heat_requirement: "heated",
  ingredients: [
    {
      item: "minecraft:cocoa_beans"
    },
    {
      item: "minecraft:sugar"
    }
  ],
  results: [
    {
      id: "kevdelights:chocolate_spread"
    }
  ]
});

event.custom({
  type: "create:deploying",
  ingredients: [
    {
      item: "kevdelights:toasted_bread_slice"
    },
    {
      item: "kevdelights:jam_spread"
    }
  ],
  results: [
    {
      id: "kevdelights:jam_toast"
    }
  ]
});

event.custom({
  type: "create:deploying",
  ingredients: [
    {
      item: "kevdelights:toasted_bread_slice"
    },
    {
      item: "kevdelights:chocolate_spread"
    }
  ],
  results: [
    {
      id: "kevdelights:chocolate_toast"
    }
  ]
});

})

ServerEvents.recipes(event => {

  event.shaped(
    'kevdelights:jar_of_jam',
    [
      'SSS',
      'SBS',
      'SSS'
    ],
    {
      S: 'kevdelights:jam_spread',
      B: 'minecraft:glass_bottle'
    }
  );

  event.shaped(
    'kevdelights:jar_of_chocolate',
    [
      'SSS',
      'SBS',
      'SSS'
    ],
    {
      S: 'kevdelights:chocolate_spread',
      B: 'minecraft:glass_bottle'
    }
  );

  event.shaped(
    'kevdelights:chefs_hat', 
    [
      'SSS',
      'ABA'
    ],
    {
      S: 'minecraft:white_wool',
      A: 'minecraft:paper',
      B: 'farmersdelight:canvas'

    }
  );

  
event.custom({
  type: "farmersdelight:cutting",
  ingredients: [
    {
      item: "kevdelights:jar_of_jam"
    }
  ],
  result: [
    {
      item: {
        count: 1,
        id: "minecraft:glass_bottle"
      }
    },
    {
      item: {
        count: 8,
        id: "kevdelights:jam_spread"
      }
    }
  ],
  sound: {
    sound_id: "minecraft:block.decorated_pot.insert"
  },
  tool: [
    {
      type: "farmersdelight:item_ability",
      action: "knife_dig"
    },
    {
      tag: "c:tools/knife"
    }
  ]
});

event.custom({
  type: "farmersdelight:cutting",
  ingredients: [
    {
      item: "kevdelights:jar_of_chocolate"
    }
  ],
  result: [
    {
      item: {
        count: 1,
        id: "minecraft:glass_bottle"
      }
    },
    {
      item: {
        count: 8,
        id: "kevdelights:chocolate_spread"
      }
    }
  ],
  sound: {
    sound_id: "minecraft:block.decorated_pot.insert"
  },
  tool: [
    {
      type: "farmersdelight:item_ability",
      action: "knife_dig"
    },
    {
      tag: "c:tools/knife"
    }
  ]
});


});
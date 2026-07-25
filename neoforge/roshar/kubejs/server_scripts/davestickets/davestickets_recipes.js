ServerEvents.recipes(event => {

event.custom({
    type: "create:pressing",
  ingredients: [
    {
      item: "createdeco:andesite_sheet"
    }
  ],
  results: [
    {
      id: "davestickets:blank_andesite_ticket"
    }
  ]
  });
  
event.custom({
    type: "create:pressing",
  ingredients: [
    {
      item: "create:golden_sheet"
    }
  ],
  results: [
    {
      id: "davestickets:blank_gold_ticket"
    }
  ]
  });

event.custom({
    type: "create:pressing",
  ingredients: [
    {
      item: "minecraft:paper"
    }
  ],
  results: [
    {
      id: "davestickets:blank_paper_ticket"
    }
  ]
  });

event.custom({
    type: "create:pressing",
  ingredients: [
    {
      item: "createdeco:zinc_sheet"
    }
  ],
  results: [
    {
      id: "davestickets:blank_zinc_ticket"
    }
  ]
  });

event.custom({
    type: "create:pressing",
  ingredients: [
    {
      item: "create:cardboard"
    }
  ],
  results: [
    {
      id: "davestickets:blank_builders_permit"
    }
  ]
  });

event.custom({
    type: "create:filling",
  ingredients: [
    {
      item: "davestickets:blank_andesite_ticket"
    },
    {
      type: "neoforge:single",
      amount: 250,
      fluid: "create_dragons_plus:black_dye"
    }
  ],
  results: [
    {
      id: "davestickets:printed_andesite_ticket"
    }
  ]
  });

event.custom({
    type: "create:filling",
  ingredients: [
    {
      item: "davestickets:blank_gold_ticket"
    },
    {
      type: "neoforge:single",
      amount: 250,
      fluid: "create_dragons_plus:black_dye"
    }
  ],
  results: [
    {
      id: "davestickets:printed_gold_ticket"
    }
  ]
  });

event.custom({
    type: "create:filling",
  ingredients: [
    {
      item: "davestickets:blank_paper_ticket"
    },
    {
      type: "neoforge:single",
      amount: 250,
      fluid: "create_dragons_plus:black_dye"
    }
  ],
  results: [
    {
      id: "davestickets:printed_paper_ticket"
    }
  ]
  });

event.custom({
    type: "create:filling",
  ingredients: [
    {
      item: "davestickets:blank_zinc_ticket"
    },
    {
      type: "neoforge:single",
      amount: 250,
      fluid: "create_dragons_plus:black_dye"
    }
  ],
  results: [
    {
      id: "davestickets:printed_zinc_ticket"
    }
  ]
  });

event.custom({
    type: "create:filling",
  ingredients: [
    {
      item: "davestickets:blank_builders_permit"
    },
    {
      type: "neoforge:single",
      amount: 250,
      fluid: "create_dragons_plus:black_dye"
    }
  ],
  results: [
    {
      id: "davestickets:builders_permit"
    }
  ]
  });

});

ItemEvents.rightClicked('davestickets:printed_andesite_ticket', event => {
  if (event.hand !== 'MAIN_HAND') return

  if (event.player.isCrouching()) {
    
    event.item.count--
    
    event.player.give('davestickets:torn_andesite_ticket')
    
    if (event.server) {
      event.server.runCommandSilent(`execute at ${event.player.username} run playsound minecraft:entity.sheep.shear master @a ~ ~ ~ 1 1`)
    }
    
    event.success()
  }
})

ItemEvents.rightClicked('davestickets:printed_gold_ticket', event => {
  if (event.hand !== 'MAIN_HAND') return

  if (event.player.isCrouching()) {
    
    event.item.count--
    
    event.player.give('davestickets:torn_gold_ticket')
    
    if (event.server) {
      event.server.runCommandSilent(`execute at ${event.player.username} run playsound minecraft:entity.sheep.shear master @a ~ ~ ~ 1 1`)
    }
    
    event.success()
  }
})

ItemEvents.rightClicked('davestickets:printed_paper_ticket', event => {
  if (event.hand !== 'MAIN_HAND') return

  if (event.player.isCrouching()) {
    
    event.item.count--
    
    event.player.give('davestickets:torn_paper_ticket')
    
    if (event.server) {
      event.server.runCommandSilent(`execute at ${event.player.username} run playsound minecraft:entity.sheep.shear master @a ~ ~ ~ 1 1`)
    }
    
    event.success()
  }
})

ItemEvents.rightClicked('davestickets:printed_zinc_ticket', event => {
  if (event.hand !== 'MAIN_HAND') return

  if (event.player.isCrouching()) {
    
    event.item.count--
    
    event.player.give('davestickets:torn_zinc_ticket')
    
    if (event.server) {
      event.server.runCommandSilent(`execute at ${event.player.username} run playsound minecraft:entity.sheep.shear master @a ~ ~ ~ 1 1`)
    }
    
    event.success()
  }
})
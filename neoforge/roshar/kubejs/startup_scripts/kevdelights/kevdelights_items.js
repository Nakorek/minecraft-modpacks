StartupEvents.registry('item', event => {
  //Hat
  event.create('kevdelights:chefs_hat')
    .displayName("Chef's Hat")
    .maxStackSize(1)
    .tooltip('§dUse /coshat to Equip')
    
  //Food
  event.create('kevdelights:bread_slice')
    .displayName('Bread Slice')
    .texture('kevdelights:item/bread_slice')
    .food(food => {
      food
        .nutrition(1)
        .saturation(1)
        .alwaysEdible()
        .eaten(ctx => {
        ctx.player.heal(2) 
      })
    })

  event.create('kevdelights:toasted_bread_slice')
    .displayName('Toasted Bread Slice')
    .texture('kevdelights:item/toasted_bread_slice')
    .food(food => {
      food
        .nutrition(2)
        .saturation(0.5)
        .alwaysEdible()
        .fastToEat()
        .eaten(ctx => {
        ctx.player.heal(2) 
      })
    })
  
  event.create('kevdelights:jam_toast')
    .displayName('Jam Toast')
    .texture('kevdelights:item/toasted_jam_bread_slice')
    .food(food => {
      food
        .nutrition(4)
        .saturation(0.25)
        .effect('minecraft:speed', 100, 1, 1)
        .eaten(ctx => {
        ctx.player.heal(3)
      })
    })

  event.create('kevdelights:chocolate_toast')
    .displayName('Chocolate Toast')
    
    .texture('kevdelights:item/toasted_chocolate_bread_slice')
    .food(food => {
      food
        .nutrition(2)
        .saturation(1)
        .effect('minecraft:speed', 100, 1, 1)
        .eaten(ctx => {
        ctx.player.heal(3) 
      })
    })

  event.create('kevdelights:jam_spread')
    .displayName('Jam Spread')
    .texture('kevdelights:item/berry_jam')
    .food(food => {
      food
        .nutrition(1)
        .saturation(0.5)
        .alwaysEdible()
        .fastToEat()
    })

  event.create('kevdelights:chocolate_spread')
    .displayName('Chocolate Spread')
    .texture('kevdelights:item/chocolate_jam')
    .food(food => {
      food
        .nutrition(1)
        .saturation(0.5)
        .alwaysEdible()
        .fastToEat()
    })
})
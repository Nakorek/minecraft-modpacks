ItemEvents.modification(event => {
  event.modify('create:minecart_contraption', item => {
    item.setMaxStackSize(1)
  })

  event.modify('easy_villagers:trader', item => {
    item.setMaxStackSize(1)
  })
})

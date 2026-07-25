BlockEvents.broken(event => {
    if (event.block.id === 'minecraft:light') {
        if (event.player && event.player.isCreative()) return

        let light15 = Item.of(`minecraft:light[minecraft:block_state={level:"15"},minecraft:custom_data={light_level:15b},minecraft:custom_name='{"color":"gold","italic":false,"text":"Light Level 15"}']`)

        event.block.set('minecraft:air')
        event.block.popItem(light15)
        event.cancel()
    }
})
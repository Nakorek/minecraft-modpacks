ServerEvents.recipes(event => {
    event.remove({ output: 'minecraft:light' })

    event.shapeless(
        Item.of(`minecraft:light[minecraft:block_state={level:"15"},minecraft:custom_data={light_level:15b},minecraft:custom_name='{"color":"gold","italic":false,"text":"Light Level 15"}']`),
        ['minecraft:glowstone_dust', '#c:glass_blocks']
    ).id('kubejs:light_base_crafting')

    for (let i = 1; i <= 15; i++) {
        let current = i
        let next = (i === 15) ? 1 : (i === 14 ? 15 : i + 1)
        
        let nextColor = (next === 15) ? "gold" : "gold"
        let nextLabel = (next === 15) ? "Light Level 15" : `Light Level ${next}`

        let inputItem = `minecraft:light[minecraft:custom_data={light_level:${current}b}]`
        
        let outputItem = Item.of(`minecraft:light[minecraft:block_state={level:"${next}"},minecraft:custom_data={light_level:${next}b},minecraft:custom_name='{"color":"${nextColor}","italic":false,"text":"${nextLabel}"}']`)

        event.shapeless(outputItem, [inputItem])
            .id(`kubejs:light_cycle_${current}_to_${next}`)
    }
})
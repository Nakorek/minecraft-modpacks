ServerEvents.recipes(event => {
    event.shaped('simplemagnet:simple_magnet', [
        'BIR',
        'B  ',
        'BIL'
    ], {
        I: 'minecraft:iron_ingot',
        L: 'minecraft:lapis_lazuli',
        B: 'create:brass_ingot',
        R: 'create:polished_rose_quartz'
    })
})
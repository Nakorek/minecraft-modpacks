RecipeViewerEvents.addEntries('item', event => {
    const hidden = [
        'create:shadow_steel_casing', 
        'create:refined_radiance_casing',
        'create:chromatic_compound',
        'create:refined_radiance',
        'create:shadow_steel',
        `minecraft:light[block_state={level:"15"},custom_data={light_level:15b},custom_name='{"color":"gold","italic":false,"text":"Light Level 15"}']`
    ]
    
    hidden.forEach(hiddenId => {
        event.add(hiddenId)
    })
})
//------------------------------------------------------------------------------------------------------------------------------------------------
// PA2 Extras - Remove Recipes
//------------------------------------------------------------------------------------------------------------------------------------------------
// Author: RicTheCoder
// Contributors: ShiftTheDev, ChosenArchitect
//
// Removes recipes based on different factors, it also fixes problems with automatic recipe generation from Create by changing the IDs of some
// recipes and suffixing them with '_manual_only'
//------------------------------------------------------------------------------------------------------------------------------------------------

// Remove by Output
// - Add the item id of the output item of the recipe and all recipes with that output will be removed
const byOutput = [
	///^sophisticatedbackpacks:(?!upgrade_base|stack_upgrade_(starter_tier|tier_1|tier_2|tier_3|tier_4)).*upgrade.*/,
	/^create_sa:(?!netherite_jetpack_chestplate$|slime_helmet$|slime_boots$|small_filling_tank$|medium_filling_tank$|large_filling_tank$|small_fueling_tank$|medium_fueling_tank$|large_fueling_tank$).*/,
	/^createcasing:(.*creative|chorium_ingot)/,
	/^createframed:(.*_)?cardboard_window_pane$/,
	/^createframed:(.*_)?cardboard_window$/,
	/^createframed:(?:shiny_)?karpboard_block$/,
	'sophisticatedbackpacks:stack_upgrade_tier_4',
	'sophisticatedbackpacks:stack_downgrade_tier_1',
	'sophisticatedbackpacks:stack_downgrade_tier_2',
	'sophisticatedbackpacks:stack_downgrade_tier_3',
	'easy_villagers:auto_trader',
    'easy_villagers:farmer',
    'easy_villagers:breeder',
    'easy_villagers:converter',
    'easy_villagers:iron_farm',
    'easy_villagers:incubator',
    'easy_villagers:inventory_viewer'
]

// Remove by ID
// - Add the recipe id for the recipe to remove
const byId = [
	'minecraft:white_shipping_container_from_dyeing_vaults',
	'minecraft:light_gray_shipping_container_from_dyeing_vaults',
	'minecraft:gray_shipping_container_from_dyeing_vaults',
	'minecraft:black_shipping_container_from_dyeing_vaults',
	'minecraft:brown_shipping_container_from_dyeing_vaults',
	'minecraft:red_shipping_container_from_dyeing_vaults',
	'minecraft:orange_shipping_container_from_dyeing_vaults',
	'minecraft:yellow_shipping_container_from_dyeing_vaults',
	'minecraft:lime_shipping_container_from_dyeing_vaults',
	'minecraft:green_shipping_container_from_dyeing_vaults',
	'minecraft:cyan_shipping_container_from_dyeing_vaults',
	'minecraft:light_blue_shipping_container_from_dyeing_vaults',
	'minecraft:blue_shipping_container_from_dyeing_vaults',
	'minecraft:purple_shipping_container_from_dyeing_vaults',
	'minecraft:magenta_shipping_container_from_dyeing_vaults',
	'minecraft:pink_shipping_container_from_dyeing_vaults'
]

// Advance Remove
// - Provide multiple options to target the removal
// - Removes the base version and adds it as '_manual_only' in order to fix Create issues (set 'manual' property to true)
// - To use regex when targeting ids (for dynamic recipes), use '$' in the start of the id
const advRemoval = [
	// { input: "reliquary:alkahestry_tome", manual: true }
]

//---[CODE]---------------------------------------------------------------------------------------------------------------------------------------

ServerEvents.recipes(event => {
    byOutput.forEach(item => event.remove({ output: item }));
    byId.forEach(item => event.remove({ id: item }));
	
	advRemoval.forEach(condition => {
		let manual = condition.manual;
		let test = condition.test;
		
		if (manual)
		{
			delete(condition.manual);
			
			let recipes = event.findRecipes(condition);
			recipes.forEach(recipe => {
				if (recipe.getId().endsWith("_manual_only"))
					return;
				
				recipe.id(recipe.getId() + "_manual_only");
			});
		}
		else		
			event.remove(condition);
	});
});
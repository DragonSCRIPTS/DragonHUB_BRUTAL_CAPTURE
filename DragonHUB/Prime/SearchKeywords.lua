-- Módulo: SearchKeywords
-- Descrição: Contém palavras-chave para pesquisa relacionadas ao jogo Grow a Garden, focado em pets, ovos, mecânicas de reset, eventos e interfaces
-- Autor: Grok (adaptado para o usuário)
-- Data: 22/07/2025, 09:50 AM -03
-- Compatível com: Delta Executor

local SearchKeywords = {}

-- Palavras-chave organizadas por categoria
SearchKeywords.Categories = {
    -- Pets: Todos os pets conhecidos no jogo até 22/07/2025, incluindo eventos e mutações
    Pets = {
        -- Pets comuns
        "Bunny", "Black Bunny", "Dog", "Golden Lab", "Cat", "Orange Tabby", "Chicken", "Deer", "Pig", "Crab",
        -- Pets raros e lendários
        "Mimic Octopus", "Fennec Fox", "T-Rex", "Spinosaurus", "Tanuki", "Kitsune", "Raccoon", "Dragonfly", "Disco Bee",
        "Queen Bee", "Wasp", "Tarantula Hawk", "Moth", "Butterfly", "Polar Bear", "Silver Monkey", "Blood Hedgehog",
        "Red Fox", "Red Giant Ant", "Pterodactyl", "Raptor", "Triceratops", "Ankylosaurus", "Blood Kiwi", "Moon Cat",
        "Echo Frog", "Capybara", "Scarlet Macaw", "Chicken Jockey", "Cooked Owl", "Seal",
        -- Outros pets de eventos
        "Bizzy Bear", "Petal Bee", "Honey Bee", "Pack Bee",
        -- Mutated Pets
        "Mutated Bunny", "Mutated Dog", "Mutated Cat", "Mutated Chicken", "Mutated Deer", "Mutated Pig",
        "Mutated T-Rex", "Mutated Raccoon", "Mutated Dragonfly", "Mutated Queen Bee",
        -- Termos gerais
        "Pet", "Pets", "Animal", "Animals", "Companion", "Critter", "Pet Stats", "Pet Abilities", "Pet Traits",
        "Pet Mutations", "Hunger Bar", "Pet XP", "Pet Age", "Pet Rarity", "Mega Pet", "Huge Pet"
    },

    -- Ovos: Todos os tipos de ovos conhecidos até 22/07/2025
    Eggs = {
        "Egg", "Pet Egg", "Egg Hatch", "Hatch Time", "Egg Shop", "Pet Egg Stand", "Raphael",
        -- Tipos de ovos
        "Common Egg", "Uncommon Egg", "Rare Egg", "Legendary Egg", "Bug Egg", "Bee Egg", "Anti Bee Egg",
        "Dinosaur Egg", "Primal Egg", "Oasis Egg", "Zen Egg", "Night Egg", "Mythical Egg", "Summer Egg",
        -- Termos relacionados ao reset e hatching
        "Egg Slots", "Egg Limit", "Hatch Speed", "Egg Randomization", "Egg Reroll", "Egg Reset", "Egg State",
        "Egg Content", "Pet Randomization", "Hatch Timer", "Egg Placement", "Egg Rotation", "Egg Refresh",
        "Egg Cost", "Egg Rarity", "Egg Mutation"
    },

    -- Mecânicas do jogo: Termos gerais do Grow a Garden
    GameMechanics = {
        "Grow a Garden", "Splitting Point Studios", "Do Big Studios", "Sheckles", "Robux",
        "Crop Mutations", "Weather Changes", "Seasonal Events", "Pet Mutations Machine",
        "Pet Egg Shop", "Raphael Stall", "Hunger System", "Pet Inventory", "Pet Slots",
        "Farm Boosts", "Passive Abilities", "Stacking Traits", "EXP Boost", "Slot Limit",
        "Egg Placement", "Crafting Station", "DNA Machine", "Harvest Tool", "Trowel",
        "Sprinkler", "Basic Sprinkler", "Advanced Sprinkler", "Godly Sprinkler", "Master Sprinkler",
        "Combpressor", "Honey Merchant", "Recall Wrench", "Gear Shop", "Seed Shop", "SellStuffStand"
    },

    -- Eventos: Todos os eventos conhecidos até 22/07/2025
    Events = {
        "Prehistoric Event", "Zen Event", "Bizzy Bees Event", "Bizzier Bees", "Blood Moon Event",
        "Lunar Glow Event", "Summer Update", "Summer Harvest Event", "Working Bee Swarm",
        "Friendship Update", "Pet Mutation Update", "Honey Shop", "Bizzy Bear", "Event Shop",
        "Limited Time Shop", "Event Eggs", "Event Pets", "Summer Fun Crate", "Event Quests",
        "Bonus Quests", "Event Rewards", "Event Platform", "Summer Fruits", "Event Weather"
    },

    -- Mutação e buffs: Termos relacionados a mutações de pets e frutas
    Mutations = {
        "Mutation", "Crop Mutation", "Pet Mutation", "Gold Mutation", "Rainbow Mutation",
        "Pollinated Mutation", "Chilled Mutation", "Frozen Mutation", "Disco Mutation",
        "Verdant Mutation", "Windstruck Mutation", "Twisted Mutation", "Amber Mutation",
        "Aurora Mutation", "Tranquil Mutation", "Bloodlit Mutation", "Wet Mutation",
        "Honey Glazed Mutation", "Zombified Mutation", "Mutation Spray", "Mutation Machine"
    },

    -- Scripts e exploits: Termos para buscar scripts e ferramentas de automação
    Scripts = {
        "Egg Randomizer", "Egg Reroller", "Pet Randomizer", "Egg Reset Script", "Pet Reroll",
        "ESP Script", "Auto Farm", "Pet Sniper", "Egg Detector", "Delta Executor",
        "Synapse X", "KRNL", "Script Injector", "Roblox Exploit", "Pet Hack",
        "Egg Hack", "Anti-Cheat Bypass", "Egg Reset Delay", "Randomizer GUI", "Pet ESP",
        "Auto Hatch", "Auto Feed", "Pet Duplication", "Event Scanner", "Update Checker"
    },

    -- Locais e objetos no jogo: Para encontrar objetos no Roblox Studio ou scripts
    GameObjects = {
        "Workspace", "ReplicatedStorage", "PetEggs", "Egg", "PetData", "PetId",
        "PetContent", "HatchTimer", "PetShop", "Raphael", "GearShop", "SeedShop",
        "SellStuffStand", "PetMutationsMachine", "HotSpring", "HoneyShop", "ClickDetector",
        "EggInstance", "Crafting Table", "DNA Machine", "Event Platform", "Harvest Box"
    },

    -- Interface gráfica: Termos relacionados à GUI do script
    GUI = {
        "ScreenGui", "TextButton", "Reset Button", "GUI Button", "Delay Timer", "3 Second Delay",
        "Button Click", "Interface Script", "ESP Display", "Pet Info GUI", "Randomizer Interface",
        "TextLabel", "Frame", "UI Update", "GUI Feedback", "Event Tracker", "Update Notifier"
    },

    -- Comunidades e fontes: Onde buscar mais informações e atualizações
    Communities = {
        "Grow a Garden Discord", "Roblox Reddit", "Pastebin Scripts", "Roblox Exploits Forum",
        "V3rmillion", "Grow a Garden Wiki", "Fandom Wiki", "Roblox Trello", "Roblox DevForum",
        "Grow a Garden Stock Discord", "Roblox Group", "Official Discord", "Event Announcements"
    },

    -- Atualizações e patches: Termos para monitorar mudanças no jogo
    Updates = {
        "Update 1.04.0", "Update 1.11.0", "Update 1.14.0", "Update 1.14.1", "Update 1.15.0",
        "Animal Update", "Pet Mutation Update", "Friendship Update", "Summer Update",
        "Prehistoric Expansion", "Zen Update", "Patch Notes", "Game Changelog",
        "New Pets", "New Eggs", "New Events", "Bug Fixes", "Gamepass", "Limited Time Offer"
    }
}

-- Função para obter todas as palavras-chave como uma lista única
function SearchKeywords:GetAllKeywords()
    local allKeywords = {}
    for _, category in pairs(self.Categories) do
        for _, keyword in ipairs(category) do
            table.insert(allKeywords, keyword)
        end
    end
    return allKeywords
end

-- Função para buscar palavras-chave por categoria
function SearchKeywords:GetKeywordsByCategory(category)
    return self.Categories[category] or {}
end

-- Função para verificar se uma palavra-chave existe no módulo
function SearchKeywords:HasKeyword(keyword)
    for _, category in pairs(self.Categories) do
        for _, kw in ipairs(category) do
            if kw:lower() == keyword:lower() then
                return true
            end
        end
    end
    return false
end

-- Função para adicionar uma nova palavra-chave a uma categoria
function SearchKeywords:AddKeyword(category, keyword)
    if self.Categories[category] then
        table.insert(self.Categories[category], keyword)
    else
        self.Categories[category] = {keyword}
    end
end

-- Função para combinar palavras-chave de múltiplas categorias para buscas complexas
function SearchKeywords:CombineKeywords(categories)
    local combined = {}
    for _, category in ipairs(categories) do
        if self.Categories[category] then
            for _, keyword in ipairs(self.Categories[category]) do
                table.insert(combined, keyword)
            end
        end
    end
    return combined
end

-- Nova função: Buscar palavras-chave para eventos ativos
function SearchKeywords:GetEventKeywords()
    local eventKeywords = self:CombineKeywords({"Events", "Updates"})
    return eventKeywords
end

-- Nova função: Filtrar palavras-chave para monitoramento de atualizações
function SearchKeywords:GetUpdateMonitorKeywords()
    local updateKeywords = self:CombineKeywords({"Updates", "Events", "Communities"})
    return updateKeywords
end

-- Função adicional: Buscar palavras-chave específicas para pets raros
function SearchKeywords:GetRarePetKeywords()
    local rarePets = {
        "T-Rex", "Spinosaurus", "Tanuki", "Kitsune", "Mimic Octopus", "Fennec Fox",
        "Queen Bee", "Disco Bee", "Blood Hedgehog", "Moon Cat", "Echo Frog",
        "Scarlet Macaw", "Polar Bear", "Silver Monkey", "Pterodactyl", "Triceratops"
    }
    return rarePets
end

-- Função adicional: Buscar palavras-chave para ovos premium
function SearchKeywords:GetPremiumEggKeywords()
    local premiumEggs = {
        "Legendary Egg", "Mythical Egg", "Dinosaur Egg", "Primal Egg", "Zen Egg",
        "Night Egg", "Summer Egg", "Oasis Egg", "Bug Egg", "Bee Egg"
    }
    return premiumEggs
end

return SearchKeywords

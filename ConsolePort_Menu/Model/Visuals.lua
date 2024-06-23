local _, env = ...;

function env:GetSpecializationVisual(specID) specID = specID or CPAPI.GetSpecialization();
    local visual = self.SpecializationVisuals[specID];
    local atlas = visual and ('talents-background-%s'):format(visual)
    if atlas and C_Texture.GetAtlasInfo(atlas) then
        return atlas, true;
    end
    return CPAPI.GetAsset([[Art\Background\%s]]):format(CPAPI.GetClassFile()), false;
end

env.SpecializationVisuals = {
	-- DK
	[0250] = 'deathknight-blood';
	[0251] = 'deathknight-frost';
	[0252] = 'deathknight-unholy';

	-- DH
	[0577] = 'demonhunter-havoc';
	[0581] = 'demonhunter-vengeance';

	-- Druid
	[0102] = 'druid-balance';
	[0103] = 'druid-feral';
	[0104] = 'druid-guardian';
	[0105] = 'druid-restoration';

	-- Evoker
	[1467] = 'evoker-devastation';
	[1468] = 'evoker-preservation';
	[1473] = 'evoker-augmentation';

	-- Hunter
	[0253] = 'hunter-beastmastery';
	[0254] = 'hunter-marksmanship';
	[0255] = 'hunter-survival';

	-- Mage
	[0062] = 'mage-arcane';
	[0063] = 'mage-fire';
	[0064] = 'mage-frost';

	-- Monk
	[0268] = 'monk-brewmaster';
	[0269] = 'monk-windwalker';
	[0270] = 'monk-mistweaver';

	-- Paladin
	[0065] = 'paladin-holy';
	[0066] = 'paladin-protection';
	[0070] = 'paladin-retribution';

	-- Priest
	[0256] = 'priest-discipline';
	[0257] = 'priest-holy';
	[0258] = 'priest-shadow';

	-- Rogue
	[0259] = 'rogue-assassination';
	[0260] = 'rogue-outlaw';
	[0261] = 'rogue-subtlety';

	-- Shaman
	[0262] = 'shaman-elemental';
	[0263] = 'shaman-enhancement';
	[0264] = 'shaman-restoration';

	-- Warlock
	[0265] = 'warlock-affliction';
	[0266] = 'warlock-demonology';
	[0267] = 'warlock-destruction';

	-- Warrior
	[0071] = 'warrior-arms';
	[0072] = 'warrior-fury';
	[0073] = 'warrior-protection';
};
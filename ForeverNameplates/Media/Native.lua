local _,NS=...
-- Paths used by actual WoW nameplate definitions; files stay in the game client.
NS.NativeMedia={
    wow_nameplate_fill={path="Interface\\TargetingFrame\\UI-TargetingFrame-BarFill"},
    wow_classic_nameplate_border={path="Interface\\Tooltips\\Nameplate-Border",coords={0,1,.5,1}},
    wow_nameplate_selection={path="Interface\\TargetingFrame\\UI-TargetingFrame-BarFill",blend="ADD"},
    wow_df_cast_background={atlas="ui-castingbar-background"},
    wow_nameplate_name={font="Fonts\\FRIZQT__.TTF",flags="",shadow={1,-1}},
    wow_classic_name={font="Fonts\\FRIZQT__.TTF",flags="",shadow={1,-1},reactionText=true},
    wow_nameplate_level={font="Fonts\\FRIZQT__.TTF",flags="",shadow={.64,-.64}},
    -- Arial Narrow is a local fallback, not the original FFXIV font.
    ffxiv_name_label={font="Fonts\\ARIALN.TTF",flags="",shadow={2,-2},outline={1,.84,.68,1}},
    ffxiv_level_label={font="Fonts\\ARIALN.TTF",flags="",shadow={2,-2},outline={1,.84,.68,1},prefix="Lv"},
}

-- Current original-nameplate import contracts; old generic profiles remain editable.
NS.ImportSizes={classic_frame={128,16},dragonflight_frame={128,32},fantasy_frame={256,32},ffxiv_hp_fill={236,12},ffxiv_enemy_icon={32,32}}
NS.ImportKinds={ffxiv_hp_fill="fill"}

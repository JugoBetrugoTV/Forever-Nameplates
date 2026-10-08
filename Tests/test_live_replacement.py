"""Live adapter regression tests; the mock does not establish client permissions."""


def test_activation_migration_once_and_persistent_opt_out(runtime, fresh_runtime):
    assert fresh_runtime.eval("NS.DB.data.live and NS.DB.data.liveMode=='replacement-v1'")
    runtime.execute('''
        assert(NS.DB.data.live and NS.DB.Current().name==NS.Presets[1].layout.name)
        local old=NS.Copy(NS.DB.data); old.liveMode=nil; old.live=false
        local migrated=NS.DB.Initialize(old)
        assert(migrated.live and migrated.liveMode=="replacement-v1")
        assert(NS.Engine.SetEnabled(false))
        local reloaded=NS.DB.Initialize(NS.Copy(NS.DB.data))
        assert(not reloaded.live and reloaded.liveMode=="replacement-v1")
    ''')


def test_real_anchor_sibling_replacement_and_live_designer_changes(runtime):
    runtime.execute('''
        local base=Mock.AddUnit("nameplate1"); base.mouse=true; base.hitTest={original=true}
        NS.Studio.Open(); NS.Engine.Add("nameplate1")
        local view=assert(NS.Engine.units.nameplate1)
        assert(view.replaced and base.UnitFrame:GetAlpha()==0)
        assert(NS.Engine.SetEnabled(false)); NS.Studio.applyButton.scripts.OnClick()
        assert(NS.DB.data.live and view.replaced and base.UnitFrame:GetAlpha()==0)
        assert(view.root.parent==base and view.root.point[1]=="CENTER")
        assert(view.root.point[2]==base.UnitFrame.healthBar and view.root.point[4]==0 and view.root.point[5]==0)
        assert(view.root.frameLevel==5 and view.root.mouse==false and base.mouse and base.hitTest.original)
        NS.Studio.Select("health"); assert(NS.Studio.Change({width=217,x=14}))
        for _,p in ipairs(view.parts) do
            if p.kind=="health" then assert(p.bar.width==217 and p.bar.point[4]==14) end
        end
        assert(view.replaced and base.UnitFrame:GetAlpha()==0)
    ''')


def test_alpha_reset_hook_restores_latest_public_alpha_and_detaches(runtime):
    runtime.execute('''
        local base=Mock.AddUnit("nameplate1"); local visual=base.UnitFrame
        visual:SetAlpha(.35); NS.Engine.Add("nameplate1")
        local view=NS.Engine.units.nameplate1
        visual:SetAlpha(.65); assert(visual:GetAlpha()==0 and view.replaced)
        SlashCmdList.FOREVERNAMEPLATES("off")
        assert(visual:GetAlpha()==.65 and not view.root:IsShown() and not NS.Engine.units.nameplate1)
        visual:SetAlpha(.8); assert(visual:GetAlpha()==.8)
        SlashCmdList.FOREVERNAMEPLATES(" apply "); assert(visual:GetAlpha()==0)
        NS.Engine.Remove("nameplate1"); assert(visual:GetAlpha()==.8)
        assert(base:IsShown() and visual:IsShown())
    ''')


def test_modern_health_container_and_independent_unitframe_pool(runtime):
    runtime.execute('''
        local first=Mock.AddUnit("nameplate1"); local visual=first.UnitFrame
        visual.HealthBarsContainer={healthBar=visual.healthBar}; visual.healthBar=nil
        NS.Engine.Add("nameplate1"); local old=NS.Engine.units.nameplate1
        assert(old.root.point[2]==visual.HealthBarsContainer.healthBar)
        local second=Mock.AddUnit("nameplate2")
        first.UnitFrame=nil; second.UnitFrame=visual
        NS.Engine.Add("nameplate2")
        assert(not old.root:IsShown() and not NS.Engine.units.nameplate1)
        local new=NS.Engine.units.nameplate2; assert(new.replaced and visual:GetAlpha()==0)
        NS.Engine.Remove("nameplate1"); assert(new.root:IsShown() and visual:GetAlpha()==0)
        NS.Engine.Remove("nameplate2"); assert(visual:GetAlpha()==1)
    ''')


def test_same_base_new_visual_restores_previous_visual(runtime):
    runtime.execute('''
        local base=Mock.AddUnit("nameplate1"); local original=base.UnitFrame
        original:SetAlpha(.4); NS.Engine.Add("nameplate1")
        local view=NS.Engine.units.nameplate1
        local other=Mock.AddUnit("nameplate2"); base.UnitFrame=other.UnitFrame
        NS.Engine.Update("nameplate1")
        assert(original:GetAlpha()==.4 and base.UnitFrame:GetAlpha()==0)
        assert(NS.Engine.units.nameplate1==view and view.root.point[2]==base.UnitFrame.healthBar)
        NS.Engine.Remove("nameplate1"); assert(base.UnitFrame:GetAlpha()==1)
    ''')


def test_rendering_failure_restores_blizzard_and_can_recover(runtime):
    runtime.execute('''
        local base=Mock.AddUnit("nameplate1"); NS.Engine.Add("nameplate1")
        local view=NS.Engine.units.nameplate1; local hp
        for _,p in ipairs(view.parts) do if p.kind=="health" then hp=p.bar end end
        local setter=hp.SetValue
        hp.SetValue=function() error("Forwarding denied") end
        NS.Engine.Update("nameplate1")
        assert(base.UnitFrame:GetAlpha()==1 and not view.root:IsShown() and not view.replaced)
        assert(NS.Engine.Status():find("Applied: 0") and NS.Engine.Status():find("Blizzard restored"))
        hp.SetValue=setter; NS.Engine.Update("nameplate1")
        assert(base.UnitFrame:GetAlpha()==0 and view.replaced and view.root:IsShown())
        local original=NS.Renderer.Update
        NS.Renderer.Update=function() error("Render failed") end
        NS.Engine.Update("nameplate1")
        assert(base.UnitFrame:GetAlpha()==1 and not view.root:IsShown())
        NS.Renderer.Update=original
    ''')


def test_denied_health_texture_keeps_blizzard(runtime):
    runtime.execute('''
        local base=Mock.AddUnit("nameplate1"); NS.Engine.Add("nameplate1")
        local view=NS.Engine.units.nameplate1
        for _,p in ipairs(view.parts) do
            if p.kind=="health" then p.bar.SetStatusBarTexture=function() return false end end
        end
        NS.Engine.Refresh()
        assert(base.UnitFrame:GetAlpha()==1 and not view.replaced and not view.root:IsShown())
    ''')


def test_restricted_visual_or_alpha_keeps_original_and_reports(runtime):
    runtime.execute('''
        local base=Mock.AddUnit("nameplate1"); base.UnitFrame.forbidden=true
        NS.Engine.Add("nameplate1"); assert(base.UnitFrame:GetAlpha()==1 and not NS.Engine.units.nameplate1)
        assert(NS.Engine.Status():find("forbidden frame"))
        base.UnitFrame.forbidden=false; base.UnitFrame.protected=true
        NS.Engine.Add("nameplate1"); assert(base.UnitFrame:GetAlpha()==1)
        base.UnitFrame.protected=false
        local setter=base.UnitFrame.SetAlpha
        base.UnitFrame.SetAlpha=function() error("Alpha mutation refused") end
        NS.Engine.Add("nameplate1")
        local view=NS.Engine.units.nameplate1
        assert(not view.root:IsShown() and not view.replaced and base.UnitFrame:GetAlpha()==1)
        assert(NS.Engine.Status():find("suppression refused"))
        base.UnitFrame.SetAlpha=setter
    ''')


def test_secret_alpha_never_suppressed_or_evaluated(runtime):
    runtime.execute('''
        local base=Mock.AddUnit("nameplate1"); local secret=Mock.Secret()
        base.UnitFrame:SetAlpha(secret); NS.Engine.Add("nameplate1")
        assert(base.UnitFrame.alpha==secret and not NS.Engine.units.nameplate1.replaced)
        base.UnitFrame:SetAlpha(1); NS.Engine.Add("nameplate1")
        local view=NS.Engine.units.nameplate1; assert(view.replaced)
        base.UnitFrame:SetAlpha(secret)
        assert(base.UnitFrame.alpha==secret and not view.root:IsShown() and not view.replaced)
        NS.Engine.Remove("nameplate1"); assert(base.UnitFrame.alpha==secret)
    ''')


def test_unitframe_event_order_retry_is_bounded_and_cancelable(runtime):
    runtime.execute('''
        local base=Mock.AddUnit("nameplate1"); local visual=base.UnitFrame; base.UnitFrame=nil
        NS.Engine.Add("nameplate1"); assert(not NS.Engine.units.nameplate1 and #Mock.timers==1)
        base.UnitFrame=visual; Mock.RunTimers()
        assert(NS.Engine.units.nameplate1.replaced and visual:GetAlpha()==0 and #Mock.timers==0)
        NS.Engine.Remove("nameplate1"); base.UnitFrame=nil; NS.Engine.Add("nameplate1")
        for i=1,5 do Mock.RunTimers() end
        assert(#Mock.timers==0 and not NS.Engine.units.nameplate1)
        NS.Engine.Remove("nameplate1"); NS.Engine.Add("nameplate1")
        NS.Engine.Remove("nameplate1"); base.UnitFrame=visual; Mock.RunTimers()
        assert(not NS.Engine.units.nameplate1 and visual:GetAlpha()==1)
    ''')


def test_discovery_existing_and_high_number_tokens(runtime):
    runtime.execute('''
        local base=Mock.AddUnit("nameplate301")
        Mock.Fire(NS.events,"PLAYER_ENTERING_WORLD")
        assert(NS.Engine.units.nameplate301.replaced and base.UnitFrame:GetAlpha()==0)
        SlashCmdList.FOREVERNAMEPLATES("status")
        assert(DEFAULT_CHAT_FRAME.messages[#DEFAULT_CHAT_FRAME.messages]:find("Applied: 1"))
        SlashCmdList.FOREVERNAMEPLATES("off"); assert(base.UnitFrame:GetAlpha()==1)
    ''')


def test_combat_first_creation_deferred_but_pooled_view_reused(runtime):
    runtime.execute('''
        local base=Mock.AddUnit("nameplate1"); Mock.combat=true; NS.Engine.Add("nameplate1")
        assert(base.UnitFrame:GetAlpha()==1 and NS.Engine.pending.nameplate1)
        Mock.combat=false; Mock.Fire(NS.events,"PLAYER_REGEN_ENABLED")
        local view=NS.Engine.units.nameplate1; assert(view.replaced)
        NS.Engine.Remove("nameplate1"); local count=#Mock.frames
        Mock.combat=true; NS.Engine.Add("nameplate1")
        assert(NS.Engine.units.nameplate1==view and view.replaced and #Mock.frames==count)
        assert(base.UnitFrame:GetAlpha()==0)
        local live=NS.DB.data.live; assert(not NS.Engine.SetEnabled(false) and NS.DB.data.live==live)
        Mock.combat=false; assert(NS.Engine.SetEnabled(false)); assert(base.UnitFrame:GetAlpha()==1)
    ''')


def test_visibility_rules_suppress_both_visuals_and_off_restores(runtime):
    runtime.execute('''
        local base=Mock.AddUnit("nameplate1"); Mock.units.nameplate1.reaction=5; Mock.units.nameplate1.isPlayer=true
        NS.DB.Current().rules.overrides.friendlyPlayers.enabled=true
        NS.DB.Current().rules.overrides.friendlyPlayers.visible=false
        NS.Engine.Add("nameplate1"); local view=NS.Engine.units.nameplate1
        assert(view.replaced and not view.root:IsShown() and base.UnitFrame:GetAlpha()==0)
        assert(NS.Engine.SetEnabled(false)); assert(base.UnitFrame:GetAlpha()==1)
    ''')


def test_newly_restricted_frames_defer_cleanup_without_mutation(runtime):
    runtime.execute('''
        local base=Mock.AddUnit("nameplate1"); NS.Engine.Add("nameplate1")
        local view=NS.Engine.units.nameplate1; base.protected=true
        NS.Engine.Remove("nameplate1")
        assert(NS.Engine.hides[view] and next(NS.Engine.restores))
        assert(base.UnitFrame:GetAlpha()==0)
        base.protected=false; Mock.plates.nameplate1=nil
        Mock.Fire(NS.events,"PLAYER_REGEN_ENABLED")
        assert(not view.root:IsShown() and base.UnitFrame:GetAlpha()==1)
        assert(not next(NS.Engine.hides) and not next(NS.Engine.restores))
    ''')


def test_missing_nameplate_api_never_crashes_world_refresh(runtime):
    runtime.execute('''
        C_NamePlate=nil; NS.Compat.Audit()
        Mock.Fire(NS.events,"PLAYER_ENTERING_WORLD")
        assert(NS.Engine.Status():find("Expected Interface 16001 and C_NamePlate"))
        assert(not NS.Engine.SetEnabled(true))
        assert(NS.Engine.SetEnabled(false))
    ''')


def test_failed_restore_does_not_recapture_suppressed_zero(runtime):
    runtime.execute('''
        local base=Mock.AddUnit("nameplate1"); local visual=base.UnitFrame
        local setter=visual.SetAlpha
        visual.SetAlpha=function(self,value)
            if Mock.denyRestore and value==1 then error("Restore denied") end
            setter(self,value)
        end
        NS.Engine.Add("nameplate1"); local view=NS.Engine.units.nameplate1
        local hp
        for _,p in ipairs(view.parts) do if p.kind=="health" then hp=p.bar end end
        local healthSetter=hp.SetValue
        hp.SetValue=function() error("Health denied") end
        Mock.denyRestore=true; NS.Engine.Update("nameplate1")
        assert(next(NS.Engine.restores) and visual:GetAlpha()==0)
        hp.SetValue=healthSetter; NS.Engine.Update("nameplate1")
        assert(not view.replaced and NS.Engine.visuals[visual].originalAlpha==1)
        Mock.denyRestore=false; NS.Engine.Update("nameplate1")
        assert(view.replaced and not next(NS.Engine.restores))
        assert(NS.Engine.SetEnabled(false)); assert(visual:GetAlpha()==1)
    ''')

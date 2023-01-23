package
{
   import com.stoicstudio.platform.Platform;
   import com.stoicstudio.platform.PlatformInput;
   import com.stoicstudio.platform.gog.GogEntryHelper;
   import com.stoicstudio.platform.steam.SteamEntryHelper;
   import com.stoicstudio.platform.tencent.TencentEntryHelper;
   import engine.anim.def.AnimFrame;
   import engine.saga.SagaDef;
   import engine.saga.action.Action_Battle;
   import engine.saga.convo.def.ConvoLinkDefVars;
   import engine.saga.save.SagaSave;
   import game.entry.EntryHelperDesktopCtor;
   import game.entry.FbEntryHelper;
   import game.entry.GameApplicationDesktopAir;
   import game.entry.IEntryHelperDesktop;
   import game.entry.OriginEntryHelper;
   import game.gui.GuiSagaOptionsConfig;
   import game.gui.InitializeGui;
   
   public class GameMainDesktop extends GameApplicationDesktopAir
   {
       
      
      public function GameMainDesktop()
      {
         var _loc1_:IEntryHelperDesktop = null;
         EntryHelperDesktopCtor.registerEntryHelper("steam",SteamEntryHelper);
         EntryHelperDesktopCtor.registerEntryHelper("origin",OriginEntryHelper);
         EntryHelperDesktopCtor.registerEntryHelper("gog",GogEntryHelper);
         EntryHelperDesktopCtor.registerEntryHelper("fb",FbEntryHelper);
         EntryHelperDesktopCtor.registerEntryHelper("tgp",TencentEntryHelper);
         super("2.59.01","saga2-v1.2.3 55","dev");
         SagaSave.SURVIVAL_RECORD_ENABLED = true;
         var _loc2_:String = "steam";
         Platform.id = _loc2_;
         _loc1_ = EntryHelperDesktopCtor.fromPlatform(_loc2_,entry.appInfo,0);
         entry.setEntryHelper(_loc1_);
         var _loc3_:Boolean = true;
         InitializeGui.initializeGuis(_loc3_,this.entry.appInfo.logger);
         PlatformInput.hasClicker = true;
         PlatformInput.hasKeyboard = true;
         GuiSagaOptionsConfig.ENABLE_FULLSCREEN = true;
         Action_Battle.USE_DANGER_BONUS_COMBATANTS = false;
         AnimFrame.COMPRESSED_FRAMES = true;
         ConvoLinkDefVars.CHECK_LINK_PATHS = true;
         Platform.supportsOSFilePicker = true;
         SagaDef.SURVIVAL_ENABLED = true;
         entry.logInfo("SagaDef.SURVIVAL_ENABLED=" + SagaDef.SURVIVAL_ENABLED);
      }
   }
}

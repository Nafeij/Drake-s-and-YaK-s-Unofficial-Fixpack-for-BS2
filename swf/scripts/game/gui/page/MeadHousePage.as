package game.gui.page
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.KeyBindGroup;
   import engine.core.fsm.State;
   import engine.entity.def.IEntityDef;
   import engine.scene.model.SceneLoader;
   import flash.ui.Keyboard;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.session.states.GameStateDataEnum;
   import game.session.states.MeadHouseState;
   import game.session.states.TownLoadState;
   import game.session.states.TownState;
   
   public class MeadHousePage extends GamePage implements IGuiMeadHouseListener
   {
       
      
      private var initCalled:Boolean = false;
      
      protected var gui:IGuiMeadHouse;
      
      private var cmd_mead_house_escape:Cmd;
      
      public function MeadHousePage(param1:GameConfig, param2:int = 2731, param3:int = 1536)
      {
         this.cmd_mead_house_escape = new Cmd("mead_house_escape",this.cmdEscapeFunc);
         super(param1,param2,param3);
      }
      
      override protected function handleStart() : void
      {
         var _loc1_:MeadHouseState = config.fsm.current as MeadHouseState;
         config.keybinder.bind(false,false,false,Keyboard.ESCAPE,this.cmd_mead_house_escape,KeyBindGroup.TOWN);
         config.keybinder.bind(false,false,false,Keyboard.BACK,this.cmd_mead_house_escape,KeyBindGroup.TOWN);
      }
      
      override public function cleanup() : void
      {
         config.keybinder.unbind(this.cmd_mead_house_escape);
         super.cleanup();
      }
      
      override protected function handleLoaded() : void
      {
         var _loc1_:MeadHouseState = null;
         if(Boolean(fullScreenMc) && !this.initCalled)
         {
            _loc1_ = config.fsm.current as MeadHouseState;
            this.gui = fullScreenMc as IGuiMeadHouse;
            this.gui.init(config.gameGuiContext,_loc1_.guiConfig,config.purchasableUnits.units,this);
            this.initCalled = true;
         }
      }
      
      public function cmdEscapeFunc(param1:CmdExec) : void
      {
         var _loc2_:MeadHouseState = null;
         if(!config.pageManager.escapeFromMarket())
         {
            _loc2_ = config.fsm.current as MeadHouseState;
            if(!_loc2_.guiConfig.disabled)
            {
               this.guiMeadHouseExit();
            }
         }
      }
      
      public function guiGoToProvingGrounds() : void
      {
         var _loc1_:MeadHouseState = config.fsm.current as MeadHouseState;
         _loc1_.handleGoToProvingGrounds();
      }
      
      public function guiMeadHouseExit() : void
      {
         var _loc1_:State = config.fsm.current;
         var _loc2_:SceneLoader = _loc1_.data.getValue(GameStateDataEnum.SCENE_LOADER);
         if(Boolean(_loc2_) && Boolean(_loc2_.scene))
         {
            config.fsm.transitionTo(TownState,_loc1_.data);
         }
         else
         {
            config.fsm.transitionTo(TownLoadState,_loc1_.data);
         }
      }
      
      public function guiMeadHouseHired(param1:IEntityDef) : void
      {
         var _loc2_:MeadHouseState = config.fsm.current as MeadHouseState;
         _loc2_.handleHired(param1);
      }
   }
}

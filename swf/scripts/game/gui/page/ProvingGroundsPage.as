package game.gui.page
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.KeyBindGroup;
   import engine.entity.def.EntityIconType;
   import engine.entity.def.IEntityAppearanceDef;
   import engine.entity.def.IEntityDef;
   import engine.resource.BitmapResource;
   import engine.scene.model.SceneLoader;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.ui.Keyboard;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.session.states.GameStateDataEnum;
   import game.session.states.ProvingGroundsState;
   import game.session.states.SceneLoadState;
   import game.session.states.SceneState;
   import game.session.states.TownLoadState;
   import game.session.states.TownState;
   
   public class ProvingGroundsPage extends GamePage implements IGuiProvingGroundsListener
   {
      
      public static var mcClazz:Class;
      
      public static var mcClazzAblPop:Class;
       
      
      private var gui:IGuiProvingGrounds;
      
      private var cmd_proving_ground_escape:Cmd;
      
      private var cmd_proving_ground_back:Cmd;
      
      private var abilityPopup:IGuiPgAbilityPopup;
      
      private var guiConfig:GuiProvingGroundsConfig;
      
      public function ProvingGroundsPage(param1:GameConfig)
      {
         this.cmd_proving_ground_escape = new Cmd("proving_ground_escape",this.cmdEscapeFunc);
         this.cmd_proving_ground_back = new Cmd("proving_ground_back",this.cmdBackFunc);
         super(param1);
      }
      
      override public function update(param1:int) : void
      {
         super.update(param1);
         if(this.gui)
         {
            this.gui.update(param1);
         }
      }
      
      override protected function handleStart() : void
      {
         var _loc3_:IEntityDef = null;
         var _loc4_:IEntityAppearanceDef = null;
         setFullPageMovieClipClass(mcClazz);
         var _loc1_:int = 0;
         while(_loc1_ < config.legend.roster.numCombatants)
         {
            _loc3_ = config.legend.roster.getEntityDef(_loc1_);
            _loc4_ = _loc3_.appearance;
            getPageResource(_loc4_.getIconUrl(EntityIconType.PARTY),BitmapResource);
            getPageResource(_loc4_.getIconUrl(EntityIconType.ROSTER),BitmapResource);
            _loc1_++;
         }
         var _loc2_:ProvingGroundsState = config.fsm.current as ProvingGroundsState;
         _loc2_.addEventListener(ProvingGroundsState.EVENT_AUTO_NAME,this.autoNameHandler);
         _loc2_.addEventListener(ProvingGroundsState.EVENT_SHOW_CLASS,this.showClassHandler);
         this.autoNameHandler(null);
         this.showClassHandler(null);
         config.keybinder.bind(false,false,false,Keyboard.ESCAPE,this.cmd_proving_ground_escape,KeyBindGroup.TOWN);
         config.keybinder.bind(false,false,false,Keyboard.BACK,this.cmd_proving_ground_back,KeyBindGroup.TOWN);
      }
      
      private function showClassHandler(param1:Event) : void
      {
         var _loc2_:ProvingGroundsState = config.fsm.current as ProvingGroundsState;
         if(Boolean(this.gui) && Boolean(_loc2_.show_class_id))
         {
            this.gui.showPromotionClassId(_loc2_.show_class_id,_loc2_.use_unit_name);
         }
      }
      
      private function autoNameHandler(param1:Event) : void
      {
         var _loc2_:ProvingGroundsState = config.fsm.current as ProvingGroundsState;
         if(this.gui)
         {
            this.gui.autoName = _loc2_.auto_name;
         }
      }
      
      override protected function handleLoaded() : void
      {
         var _loc1_:ProvingGroundsState = null;
         if(Boolean(mcClazzAblPop) && !this.abilityPopup)
         {
            this.abilityPopup = new mcClazzAblPop() as IGuiPgAbilityPopup;
            loadGuiBitmaps(this.abilityPopup.mc);
         }
         if(fullScreenMc && !this.gui && (!mcClazzAblPop || this.abilityPopup))
         {
            _loc1_ = config.fsm.current as ProvingGroundsState;
            this.gui = fullScreenMc as IGuiProvingGrounds;
            this.guiConfig = _loc1_.guiConfig;
            this.guiConfig.roster.enableItems = false;
            this.guiConfig.promotion.enableVariation = true;
            this.gui.init(config.gameGuiContext,_loc1_.guiConfig,this,this.abilityPopup);
            this.autoNameHandler(null);
            this.showClassHandler(null);
         }
      }
      
      public function guiProvingGroundsReady() : void
      {
         throw new IllegalOperationError("Nope");
      }
      
      public function guiProvingGroundsExit() : void
      {
         var _loc1_:ProvingGroundsState = config.fsm.current as ProvingGroundsState;
         if(!_loc1_)
         {
            return;
         }
         var _loc2_:SceneLoader = _loc1_.data.getValue(GameStateDataEnum.SCENE_LOADER);
         var _loc3_:Boolean = _loc1_.data.getValue(GameStateDataEnum.SCENE_IS_TOWN);
         if(Boolean(_loc2_) && Boolean(_loc2_.scene))
         {
            if(_loc3_)
            {
               config.fsm.current.data.setValue(GameStateDataEnum.SCENE_AUTOPAN,false);
               config.fsm.transitionTo(TownState,_loc1_.data);
            }
            else
            {
               config.fsm.transitionTo(SceneState,_loc1_.data);
            }
         }
         else if(_loc3_)
         {
            config.fsm.current.data.setValue(GameStateDataEnum.SCENE_AUTOPAN,false);
            config.fsm.transitionTo(TownLoadState,_loc1_.data);
         }
         else
         {
            config.fsm.transitionTo(SceneLoadState,_loc1_.data);
         }
      }
      
      override public function cleanup() : void
      {
         config.keybinder.unbind(this.cmd_proving_ground_escape);
         config.keybinder.unbind(this.cmd_proving_ground_back);
         super.cleanup();
         if(this.gui)
         {
            this.gui.cleanup();
            this.gui = null;
         }
      }
      
      public function guiProvingGroundsDisplayCharacterDetails(param1:IEntityDef) : void
      {
         var _loc2_:ProvingGroundsState = config.fsm.current as ProvingGroundsState;
         _loc2_.handleDisplayCharacterDetails(param1);
      }
      
      public function guiProvingGroundsDisplayPromotion(param1:IEntityDef) : void
      {
         var _loc2_:ProvingGroundsState = config.fsm.current as ProvingGroundsState;
         _loc2_.handleDisplayPromotion(param1);
      }
      
      public function guiProvingGroundsHandlePromotion(param1:IEntityDef) : void
      {
         var _loc2_:ProvingGroundsState = config.fsm.current as ProvingGroundsState;
         _loc2_.handlePromotion(param1);
      }
      
      public function guiProvingGroundsCloseQuestionPages() : void
      {
         var _loc1_:ProvingGroundsState = config.fsm.current as ProvingGroundsState;
         _loc1_.handleProvingGroundsCloseQuestionPages();
      }
      
      public function guiProvingGroundsQuestionClick() : void
      {
         var _loc1_:ProvingGroundsState = config.fsm.current as ProvingGroundsState;
         _loc1_.handleProvingGroundsQuestionClick();
      }
      
      public function guiProvingGroundsNamingAccept() : void
      {
         var _loc1_:ProvingGroundsState = config.fsm.current as ProvingGroundsState;
         _loc1_.handleProvingGroundsNamingAccept();
      }
      
      public function guiProvingGroundsNamingMode() : void
      {
         var _loc1_:ProvingGroundsState = config.fsm.current as ProvingGroundsState;
         _loc1_.handleProvingGroundsNamingMode();
      }
      
      public function guiProvingGroundsVariationOpened() : void
      {
         var _loc1_:ProvingGroundsState = config.fsm.current as ProvingGroundsState;
         _loc1_.handleProvingGroundsVariationOpened();
      }
      
      public function guiProvingGroundsVariationSelected() : void
      {
         var _loc1_:ProvingGroundsState = config.fsm.current as ProvingGroundsState;
         _loc1_.handleProvingGroundsVariationSelected();
      }
      
      public function cmdEscapeFunc(param1:CmdExec) : void
      {
         var _loc2_:ProvingGroundsState = null;
         if(!config.pageManager.escapeFromMarket())
         {
            _loc2_ = config.fsm.current as ProvingGroundsState;
            if(!_loc2_.guiConfig.disabled)
            {
               this.guiProvingGroundsExit();
            }
         }
      }
      
      public function cmdBackFunc(param1:CmdExec) : void
      {
         var _loc2_:ProvingGroundsState = null;
         if(!config.pageManager.escapeFromMarket())
         {
            _loc2_ = config.fsm.current as ProvingGroundsState;
            if(!_loc2_.guiConfig.disabled)
            {
               if(this.gui)
               {
                  this.gui.back();
               }
            }
         }
      }
   }
}

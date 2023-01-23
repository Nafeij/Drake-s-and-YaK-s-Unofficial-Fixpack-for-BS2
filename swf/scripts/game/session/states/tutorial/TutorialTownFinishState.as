package game.session.states.tutorial
{
   import engine.core.TutorialTooltipAlign;
   import engine.core.TutorialTooltipAnchor;
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.locale.LocaleCategory;
   import engine.core.logging.ILogger;
   import engine.scene.view.SceneViewSprite;
   import flash.events.Event;
   import game.gui.IGuiDialog;
   import game.session.states.TownState;
   import game.view.TutorialTooltip;
   
   public class TutorialTownFinishState extends TownState
   {
       
      
      private var _view:SceneViewSprite;
      
      public var helper:HelperTutorialState;
      
      public function TutorialTownFinishState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      public function mode_greathall(param1:Function) : void
      {
         var self:Function = param1;
         var p:String = "TownPage|scene_view|landscape_view|back_6 (greathall)|sprite_ui_greathall_1";
         var anchor_offset:Number = 75;
         this.helper.tt = config.tutorialLayer.createTooltip(p,TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.BOTTOM,anchor_offset,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_town_goto_greathall"),false,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.tt = null;
            chatEnabled = true;
            bannerButtonEnabled = true;
            scene.allClickablesDisabled = false;
            config.alerts.enabled = true;
            helper.next(mode_greathall);
         });
      }
      
      public function mode_tutorials(param1:Function) : void
      {
         var dialog:IGuiDialog;
         var title:String;
         var body:String;
         var ok:String;
         var self:Function = param1;
         this.helper.tt = null;
         dialog = config.gameGuiContext.createDialog();
         title = config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_town_end_tutorials_title");
         body = config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_town_end_tutorials_body");
         ok = config.context.locale.translate(LocaleCategory.GUI,"ok");
         dialog.openDialog(title,body,ok,function(param1:String):void
         {
            phase = StatePhase.COMPLETED;
         });
      }
      
      override protected function handleCleanup() : void
      {
         super.handleCleanup();
         helpEnabled = true;
      }
      
      override public function handlePageReady() : void
      {
         super.handlePageReady();
         gameFsm.updateGameLocation("loc_tutorial");
         helpEnabled = false;
         chatEnabled = false;
         bannerButtonEnabled = false;
         scene.allClickablesDisabled = true;
         config.alerts.enabled = false;
         this._view = loader.viewSprite;
         this.helper = new HelperTutorialState(this,[this.mode_greathall,this.mode_tutorials]);
         this.helper.next(null);
      }
   }
}

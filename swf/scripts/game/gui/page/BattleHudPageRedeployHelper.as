package game.gui.page
{
   import engine.battle.fsm.BattleFsmEvent;
   import game.cfg.GameConfig;
   import game.gui.battle.IGuiRedeployment;
   
   public class BattleHudPageRedeployHelper
   {
      
      public static var mcClazzRedeployment:Class;
      
      public static var mcClazzRosterTitle:Class;
      
      public static var mcClazzEntityFrame:Class;
       
      
      private var _redeployment:IGuiRedeployment;
      
      private var _bhPage:BattleHudPage;
      
      private var _config:GameConfig;
      
      public function BattleHudPageRedeployHelper(param1:BattleHudPage, param2:GameConfig)
      {
         super();
         this._bhPage = param1;
         this._config = param2;
      }
      
      private function instantiateRedeploymentGui() : void
      {
         if(mcClazzRedeployment && !this._redeployment && Boolean(this._bhPage))
         {
            this._redeployment = new mcClazzRedeployment() as IGuiRedeployment;
            this._bhPage.addChild(this._redeployment.displayObject);
            this._redeployment.setRedeploymentEntityFrameClazz(mcClazzEntityFrame);
            this._redeployment.init(this._config.gameGuiContext,this._bhPage);
         }
      }
      
      public function interactHandler(param1:BattleFsmEvent) : void
      {
         if(this._redeployment)
         {
            this._redeployment.interactHandler(param1);
         }
      }
      
      public function showRedeploymentGui() : void
      {
         if(!this._redeployment)
         {
            this.instantiateRedeploymentGui();
         }
         else
         {
            this._redeployment.refresh();
         }
         if(this._redeployment)
         {
            this._bhPage.questionMarkHelpEnabled = false;
            this._redeployment.displayObject.visible = true;
         }
      }
      
      public function activateRedeploymentGui() : void
      {
         if(!this._redeployment)
         {
            return;
         }
         this._redeployment.activateGp();
      }
      
      public function hideRedeploymentGui() : void
      {
         if(this._redeployment)
         {
            this._redeployment.displayObject.visible = false;
            this._redeployment.deactivateGp();
         }
      }
      
      public function resizeHandler(param1:Number, param2:Number) : void
      {
         if(this._redeployment)
         {
            this._redeployment.resizeHandler(param1,param2);
         }
      }
      
      public function cleanup() : void
      {
         if(this._redeployment)
         {
            if(Boolean(this._bhPage) && this._redeployment.displayObject.parent == this._bhPage)
            {
               this._bhPage.removeChild(this._redeployment.displayObject);
            }
            this._redeployment.cleanup();
            this._redeployment = null;
         }
      }
   }
}

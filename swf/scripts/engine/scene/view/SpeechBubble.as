package engine.scene.view
{
   import com.stoicstudio.platform.Platform;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.core.render.BoundedCamera;
   import engine.core.render.Camera;
   import engine.entity.def.IEntityDef;
   import engine.gui.IGuiSpeechBubble;
   import engine.gui.page.Page;
   import flash.display.MovieClip;
   import flash.utils.getTimer;
   
   public class SpeechBubble
   {
       
      
      public var msg:String;
      
      public var speakerId:String;
      
      public var anchor:String;
      
      public var timeout:Number;
      
      public var x:Number = 0;
      
      public var y:Number = 0;
      
      public var positioner:ISpeechBubblePositioner;
      
      private var _gui:IGuiSpeechBubble;
      
      public var entDef:IEntityDef;
      
      public var bent:IBattleEntity;
      
      public var expire:int = 0;
      
      public var positionerInfo;
      
      public var display:MovieClip;
      
      private var scenePage:Page;
      
      public var expireImmediately:Boolean;
      
      public var alpha:Number = 1;
      
      public function SpeechBubble(param1:Page, param2:String, param3:Number, param4:IBattleEntity, param5:IEntityDef, param6:String, param7:String, param8:*, param9:ISpeechBubblePositioner)
      {
         super();
         this.scenePage = param1;
         this.msg = param2;
         this.timeout = param3;
         this.positioner = param9;
         this.entDef = param5;
         this.bent = param4;
         this.expire = getTimer() + param3 * 1000;
         this.positionerInfo = param8;
         if(param4)
         {
            param4.addEventListener(BattleEntityEvent.ENABLED,this.entityEnabledHandler);
         }
         this.update(null);
      }
      
      private function entityEnabledHandler(param1:BattleEntityEvent) : void
      {
         if(this.bent)
         {
            if(this.bent.enabled)
            {
               return;
            }
            this.bent.removeEventListener(BattleEntityEvent.ENABLED,this.entityEnabledHandler);
         }
         this.expire = 0;
         this.expireImmediately = true;
      }
      
      public function get gui() : IGuiSpeechBubble
      {
         return this._gui;
      }
      
      public function set gui(param1:IGuiSpeechBubble) : void
      {
         var _loc2_:MovieClip = null;
         if(this._gui)
         {
            this._gui.cleanup();
         }
         this._gui = param1;
         if(this._gui)
         {
            this._gui.x = this.x;
            this._gui.y = this.y;
         }
      }
      
      public function setPosition(param1:Number, param2:Number, param3:Boolean) : void
      {
         var _loc4_:MovieClip = null;
         if(param3)
         {
            this.x = this.scenePage.width / 2 + param1;
            this.y = this.scenePage.height / 2 + param2;
         }
         else
         {
            this.x = param1;
            this.y = param2;
         }
         if(this._gui)
         {
            _loc4_ = this._gui as MovieClip;
            if(_loc4_)
            {
               _loc4_.x = this.x;
               _loc4_.y = this.y;
            }
         }
      }
      
      public function update(param1:Camera) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:Number = NaN;
         if(this.expireImmediately)
         {
            return;
         }
         if(this.positioner)
         {
            this.positioner.positionSpeechBubble(this);
         }
         if(this._gui)
         {
            _loc2_ = this._gui as MovieClip;
            _loc3_ = Math.min(1.25,BoundedCamera.dpiFingerScale * Platform.textScale);
            _loc2_.scaleX = _loc2_.scaleY = _loc3_;
            _loc2_.alpha = this.alpha;
         }
      }
      
      public function cleanup() : void
      {
         if(this.bent)
         {
            this.bent.removeEventListener(BattleEntityEvent.REMOVED,this.entityEnabledHandler);
            this.bent = null;
         }
         this.positioner = null;
         this.gui = null;
      }
   }
}

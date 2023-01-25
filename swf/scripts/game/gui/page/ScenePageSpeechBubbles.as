package game.gui.page
{
   import com.stoicstudio.platform.Platform;
   import engine.battle.board.model.IBattleEntity;
   import engine.entity.def.IEntityDef;
   import engine.gui.IGuiSpeechBubble;
   import engine.saga.Saga;
   import engine.saga.SpeakEvent;
   import engine.scene.view.ISpeechBubblePositioner;
   import engine.scene.view.SpeechBubble;
   import flash.display.MovieClip;
   import flash.utils.getTimer;
   import game.cfg.GameConfig;
   
   public class ScenePageSpeechBubbles
   {
      
      public static var mcClazzSpeechieLeft:Class;
      
      public static var mcClazzSpeechieRight:Class;
       
      
      private var scenePage:ScenePage;
      
      private var config:GameConfig;
      
      private var saga:Saga;
      
      private var bubbles:Vector.<SpeechBubble>;
      
      private var expires:Vector.<int>;
      
      public function ScenePageSpeechBubbles(param1:ScenePage)
      {
         this.bubbles = new Vector.<SpeechBubble>();
         this.expires = new Vector.<int>();
         super();
         this.scenePage = param1;
         this.config = param1.config;
      }
      
      public function cleanup() : void
      {
         var _loc1_:SpeechBubble = null;
         if(this.saga)
         {
            this.saga = null;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this.bubbles.length)
         {
            _loc1_ = this.bubbles[_loc2_];
            _loc1_.cleanup();
            _loc2_++;
         }
         this.bubbles = null;
         this.scenePage = null;
         this.config = null;
         this.expires = null;
      }
      
      public function doInitReady() : void
      {
         this.saga = this.config.saga;
      }
      
      public function update() : void
      {
         var _loc2_:SpeechBubble = null;
         var _loc1_:int = getTimer();
         var _loc3_:int = 0;
         while(_loc3_ < this.bubbles.length)
         {
            _loc2_ = this.bubbles[_loc3_];
            if(!_loc2_.expireImmediately)
            {
               _loc2_.expire += Platform.pauseDuration;
               _loc2_.update(this.scenePage.scene._camera);
            }
            if(_loc2_.expireImmediately || _loc2_.expire <= _loc1_)
            {
               _loc2_.cleanup();
               this.bubbles.splice(_loc3_,1);
               _loc3_--;
            }
            _loc3_++;
         }
      }
      
      public function speechBubbler(param1:SpeakEvent, param2:*, param3:ISpeechBubblePositioner) : SpeechBubble
      {
         var _loc4_:String = !!param1.speakerDef ? String(param1.speakerDef.id) : null;
         return this.createSpeechBubble(param1.msg,param1.timeout,param1.speakerEnt,param1.speakerDef,_loc4_,param1.anchor,param2,param3,param1.direction,param1.notranslate);
      }
      
      public function createSpeechBubble(param1:String, param2:Number, param3:IBattleEntity, param4:IEntityDef, param5:String, param6:String, param7:*, param8:ISpeechBubblePositioner, param9:String, param10:Boolean) : SpeechBubble
      {
         var _loc12_:IGuiSpeechBubble = null;
         var _loc11_:SpeechBubble = new SpeechBubble(this.scenePage,param1,param2,param3,param4,param5,param6,param7,param8);
         if(param9 == "left")
         {
            _loc12_ = new mcClazzSpeechieLeft() as IGuiSpeechBubble;
         }
         else
         {
            _loc12_ = new mcClazzSpeechieRight() as IGuiSpeechBubble;
         }
         _loc12_.init(this.config.gameGuiContext,param3,param4,param1,param2,param10);
         _loc11_.gui = _loc12_;
         this.bubbles.push(_loc11_);
         this.scenePage.addChild(_loc11_.gui as MovieClip);
         return _loc11_;
      }
   }
}

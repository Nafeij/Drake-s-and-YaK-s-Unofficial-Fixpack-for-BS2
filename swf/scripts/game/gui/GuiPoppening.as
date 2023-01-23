package game.gui
{
   import com.greensock.TweenMax;
   import engine.battle.Fastall;
   import engine.core.locale.Locale;
   import engine.entity.def.EntityIconType;
   import engine.entity.def.IEntityDef;
   import engine.saga.convo.Convo;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class GuiPoppening extends GuiConvoBase implements IGuiConvo
   {
      
      public static const TEXT_BOTTOM_MARGIN:Number = 20;
      
      public static const OPTIONS_TOP_MARGIN:Number = 50;
       
      
      public var _thread_top:MovieClip;
      
      public var _backdrop:MovieClip;
      
      private var speakerIcon:GuiIcon;
      
      private var maxBackdropY:Number = 0;
      
      public var _tops:Vector.<MovieClip>;
      
      private var ICON_TEXT_OFFSET:Number = 160;
      
      private var ICON_TEXT_MINHEIGHT:Number = 150;
      
      public function GuiPoppening()
      {
         this._tops = new Vector.<MovieClip>();
         super(EntityIconType.ROSTER);
         _showConvoCursorTextVisibilityDefault = false;
      }
      
      override public function init(param1:IGuiContext, param2:Convo, param3:Boolean) : void
      {
         var _loc5_:MovieClip = null;
         super.init(param1,param2,param3);
         this._tops.push(getChildByName("thread_top") as MovieClip);
         var _loc4_:int = 1;
         while(_loc4_ < 5)
         {
            _loc5_ = getChildByName("top_" + _loc4_) as MovieClip;
            if(!_loc5_)
            {
               break;
            }
            this._tops.push(_loc5_);
            _loc4_++;
         }
         if(this._tops[0] == null && this._tops.length > 1)
         {
            this._tops[0] = this._tops[1];
         }
         this._backdrop = requireGuiChild("backdrop") as MovieClip;
         this._hideTops();
         this.maxBackdropY = this._backdrop.y;
         this._backdrop.y -= this._backdrop.height;
      }
      
      private function _hideTops() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this._tops.length)
         {
            this._tops[_loc1_].visible = false;
            _loc1_++;
         }
      }
      
      override protected function start() : void
      {
         this._backdrop.y -= this._backdrop.height;
         this.textVisible = false;
         this._backdrop.visible = false;
         this._hideTops();
         var _loc1_:int = Math.max(0,Math.min(_convo.poppening_top,this._tops.length - 1));
         this._thread_top = this._tops[_loc1_];
         this.speaker = null;
         super.start();
      }
      
      override protected function layoutChoices() : void
      {
         var _loc2_:Number = NaN;
         if(this.speakerIcon)
         {
            _text.x = originalTextX + this.ICON_TEXT_OFFSET;
            _text.width = originalTextWidth - this.ICON_TEXT_OFFSET;
         }
         else
         {
            _text.x = originalTextX;
            _text.width = originalTextWidth;
         }
         _text.height = _text.textHeight + TEXT_BOTTOM_MARGIN;
         if(this.speakerIcon)
         {
            _text.height = Math.max(_text.height,this.ICON_TEXT_MINHEIGHT);
         }
         var _loc1_:Number = _text.height;
         _loc2_ = maxTextHeight - _loc1_;
         if(this._thread_top)
         {
            this._thread_top.visible = true;
         }
         this.textVisible = false;
         this._backdrop.visible = true;
         var _loc3_:int = this.maxBackdropY - _loc2_;
         if(Fastall.gui)
         {
            this._backdrop.y = _loc3_;
            this.backdropRetractionHandler();
         }
         else
         {
            TweenMax.to(this._backdrop,0.25,{
               "y":_loc3_,
               "onComplete":this.backdropRetractionHandler
            });
         }
      }
      
      private function set textVisible(param1:Boolean) : void
      {
         var _loc2_:Boolean = _text.visible;
         _text.visible = param1 && ready;
         if(this.speakerIcon)
         {
            this.speakerIcon.visible = param1 && Boolean(_speaker) && ready;
         }
         if(_loc2_ != _text.visible)
         {
            Locale.updateTextFieldGuiGpTextHelper(_text);
         }
      }
      
      private function backdropRetractionHandler() : void
      {
         var _loc2_:Number = NaN;
         var _loc4_:GuiPoppeningChoice = null;
         this.textVisible = true;
         var _loc1_:Point = measureChoices();
         _loc2_ = _text.y + _text.height + OPTIONS_TOP_MARGIN;
         var _loc3_:int = 0;
         while(_loc3_ < choiceCount)
         {
            _loc4_ = choices[_loc3_];
            _loc4_.visible = true;
            _loc4_.y = _loc2_;
            _loc2_ += _loc4_.height;
            _loc4_.x = originalTextX + (originalTextWidth - _loc1_.x) / 2;
            _loc3_++;
         }
         layoutGpNav();
      }
      
      override public function set speaker(param1:IEntityDef) : void
      {
         if(super.speaker == param1)
         {
            return;
         }
         if(this.speakerIcon)
         {
            this.speakerIcon.release();
            removeChild(this.speakerIcon);
            this.speakerIcon = null;
         }
         super.speaker = param1;
         if(speaker)
         {
            this.speakerIcon = context.getEntityIcon(speaker,EntityIconType.ROSTER);
            addChild(this.speakerIcon);
            this.speakerIcon.x = originalTextX - 16;
            this.speakerIcon.y = _text.y - 16;
            this.speakerIcon.visible = false;
         }
      }
   }
}

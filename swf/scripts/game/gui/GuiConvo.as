package game.gui
{
   import com.greensock.TweenMax;
   import com.stoicstudio.platform.Platform;
   import engine.entity.def.EntityIconType;
   import engine.entity.def.IEntityDef;
   import engine.saga.convo.Convo;
   import flash.geom.Point;
   
   public class GuiConvo extends GuiConvoBase implements IGuiConvo
   {
      
      public static const MARGIN:Number = 20;
      
      private static const SAFE_ZONE_Y_OFFSET:Number = -50;
       
      
      protected var originalbannerNameX:Number = 0;
      
      protected var originalTextNameX:Number = 0;
      
      protected var _cropSize:Point;
      
      protected var _retraction:Number = 620;
      
      private var speakerIcon:GuiIcon;
      
      private var BANNER_LEFT_MARGIN:Number = 40;
      
      private var BANNER_NAME_EXTRA_MARGIN:Number = 20;
      
      public function GuiConvo()
      {
         this._cropSize = new Point(Number.MAX_VALUE,Number.MAX_VALUE);
         super(EntityIconType.ROSTER);
      }
      
      override public function getDebugString() : String
      {
         return "GuiConvo";
      }
      
      override public function init(param1:IGuiContext, param2:Convo, param3:Boolean) : void
      {
         super.init(param1,param2,param3);
         this.convo = param2;
         this.originalbannerNameX = _bannerName.x;
         this.originalTextNameX = _textName.x;
      }
      
      override public function cleanup() : void
      {
         TweenMax.killTweensOf(this);
         super.cleanup();
      }
      
      override public function handleLocaleChange() : void
      {
         super.handleLocaleChange();
      }
      
      private function buttonNextHandler(param1:ButtonWithIndex) : void
      {
         _convo.next();
      }
      
      private function buttonEndHandler(param1:ButtonWithIndex) : void
      {
         _convo.next();
      }
      
      override protected function layoutChoices() : void
      {
         var _loc1_:Number = this._cropSize.x / scaleX;
         var _loc2_:Number = this._cropSize.y / scaleX;
         _bannerName.x = Math.max(this.originalbannerNameX,-_loc1_ / 2 + this.BANNER_LEFT_MARGIN + this.BANNER_NAME_EXTRA_MARGIN);
         _textName.x = _bannerName.x + (this.originalTextNameX - this.originalbannerNameX);
         if(this.speakerIcon)
         {
            if(_cursor && _cursor.camera && _speaker != _cursor.camera)
            {
               this.speakerIcon.x = _bannerName.x - 50;
               this.speakerIcon.y = _bannerName.y + (_bannerName.height - 100) / 2 - 10;
               this.speakerIcon.visible = true;
            }
            else
            {
               this.speakerIcon.visible = false;
            }
         }
         _text.width = Math.min(originalTextWidth,_loc1_ - this.BANNER_LEFT_MARGIN * 2);
         _text.x = -_text.width / 2;
         _text.height = _text.textHeight + MARGIN;
         if(choiceCount == 0)
         {
         }
         this.placeChoices();
      }
      
      private function placeChoices() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Point = null;
         var _loc3_:int = 0;
         var _loc4_:GuiPoppeningChoice = null;
         _loc1_ = _text.y + _text.height + MARGIN;
         if(choiceCount > 0)
         {
            _loc2_ = measureChoices();
            _loc3_ = 0;
            while(_loc3_ < choiceCount)
            {
               _loc4_ = choices[_loc3_];
               _loc4_.visible = true;
               _loc4_.mouseEnabled = true;
               _loc4_.y = _loc1_;
               _loc1_ += _loc4_.height;
               _loc4_.x = originalTextX + (originalTextWidth - _loc2_.x) / 2;
               _loc3_++;
            }
         }
         else
         {
            _buttonNext.y = _loc1_;
            _buttonEnd.y = _loc1_;
            _loc1_ += _buttonNext.height / 2 + 10;
         }
         TweenMax.killTweensOf(this);
         if(this.retraction != -_loc1_)
         {
            allowGp = false;
            TweenMax.to(this,0.5,{
               "retraction":-_loc1_,
               "onComplete":this.retractionCompleteHandler
            });
         }
         else
         {
            this.retractionCompleteHandler();
         }
      }
      
      private function choiceCallback(param1:GuiPoppeningChoice) : void
      {
         if(!_convo)
         {
            return;
         }
         if(param1.id == "@next")
         {
            _convo.next();
         }
         else if(param1.id == "@end")
         {
            _convo.next();
         }
         else if(param1.id == "@opt")
         {
            _convo.select(param1.opt);
         }
      }
      
      override public function setConvoRect(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
         this.setCrop(param3,param4);
         x = param3 / 2;
         this.updateY();
         layoutGpNav();
      }
      
      override public function set speaker(param1:IEntityDef) : void
      {
         var _loc2_:int = 0;
         if(super.speaker == param1)
         {
            return;
         }
         super.speaker = param1;
         if(this.speakerIcon)
         {
            removeChild(this.speakerIcon);
            this.speakerIcon.release();
            this.speakerIcon = null;
         }
         if(_speaker)
         {
            this.speakerIcon = context.getEntityIcon(_speaker,EntityIconType.ROSTER);
            this.speakerIcon.setTargetSize(100,100);
            this.speakerIcon.layout = GuiIconLayoutType.STRETCH;
            _loc2_ = getChildIndex(_bannerName);
            addChildAt(this.speakerIcon,_loc2_ + 1);
            this.speakerIcon.visible = true;
         }
      }
      
      public function setCrop(param1:Number, param2:Number) : void
      {
         this._cropSize.setTo(param1,param2);
         this.layoutChoices();
         layoutGpNav();
      }
      
      public function get retraction() : Number
      {
         return this._retraction;
      }
      
      public function set retraction(param1:Number) : void
      {
         if(this._retraction == param1)
         {
            return;
         }
         this._retraction = param1;
         this.updateY();
      }
      
      private function updateY() : void
      {
         y = this._cropSize.y + this._retraction * scaleX;
         if(Platform.requiresUiSafeZoneBuffer)
         {
            y += SAFE_ZONE_Y_OFFSET;
         }
      }
      
      private function retractionCompleteHandler() : void
      {
         allowGp = true;
      }
   }
}

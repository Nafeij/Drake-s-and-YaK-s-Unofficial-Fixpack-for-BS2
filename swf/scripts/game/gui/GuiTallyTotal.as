package game.gui
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Back;
   import engine.gui.GuiContextEvent;
   import flash.display.DisplayObject;
   import flash.text.TextField;
   import game.saga.tally.ITallyStep;
   import game.saga.tally.TallyStep;
   
   public class GuiTallyTotal extends GuiBase implements IGuiTallyTotal
   {
      
      private static const DAYS_TEXT_FORMAT:String = "tally_value_days_format";
      
      private static const HOURS_TEXT_FORMAT:String = "tally_value_hours_format";
       
      
      private var _title:TextField;
      
      private var _value:TextField;
      
      private var _numValue:Number = 0;
      
      private var _displayedValue:Number = 123;
      
      private var _displayHours:Boolean = false;
      
      private var _title_initial:TextField;
      
      private var _title_tally:TextField;
      
      private var _title_final:TextField;
      
      private var _value_initial:TextField;
      
      private var _value_tally:TextField;
      
      private var _value_final:TextField;
      
      private var _title_loc_key:String;
      
      private var _value_loc_format:String;
      
      private var _textPulseDuration:Number = 0.3;
      
      private var _textOffset:Number = 0;
      
      private var _anims:Vector.<TallyTotalAnim>;
      
      private var _completeAnims:Vector.<TallyTotalAnim>;
      
      public function GuiTallyTotal()
      {
         this._anims = new Vector.<TallyTotalAnim>();
         this._completeAnims = new Vector.<TallyTotalAnim>();
         super();
      }
      
      public function init(param1:IGuiContext) : void
      {
         initGuiBase(param1);
         this._title_initial = requireGuiChild("title_initial") as TextField;
         registerScalableTextfieldAlign(this._title_initial,"right");
         this._title_initial.visible = false;
         this._title_tally = requireGuiChild("title_tally") as TextField;
         registerScalableTextfieldAlign(this._title_tally,"right");
         this._title_tally.visible = false;
         this._title_final = requireGuiChild("title_final") as TextField;
         registerScalableTextfieldAlign(this._title_final,"right");
         this._title_final.visible = false;
         this._value_initial = requireGuiChild("value_initial") as TextField;
         registerScalableTextfieldAlign(this._value_initial,"left");
         this._value_initial.visible = false;
         this._value_tally = requireGuiChild("value_tally") as TextField;
         registerScalableTextfieldAlign(this._value_tally,"left");
         this._value_tally.visible = false;
         this._value_final = requireGuiChild("value_final") as TextField;
         registerScalableTextfieldAlign(this._value_final,"left");
         this._value_final.visible = false;
         _context.addEventListener(GuiContextEvent.LOCALE,this.localeHandler);
      }
      
      public function get title() : TextField
      {
         return this._title;
      }
      
      public function set title(param1:TextField) : void
      {
         if(this._title == param1)
         {
            return;
         }
         if(this._title)
         {
            this._title.visible = false;
            param1.text = this._title.text;
         }
         param1.visible = true;
         this._title = param1;
         _context.locale.fixTextFieldFormat(this._title);
      }
      
      public function get displayHours() : Boolean
      {
         return this._displayHours;
      }
      
      public function set displayHours(param1:Boolean) : void
      {
         this._displayHours = param1;
      }
      
      public function get value() : TextField
      {
         return this._value;
      }
      
      public function set value(param1:TextField) : void
      {
         if(this._value == param1)
         {
            return;
         }
         if(this._value)
         {
            this._value.visible = false;
            param1.text = this._value.text;
         }
         param1.visible = true;
         this._value = param1;
         _context.locale.fixTextFieldFormat(this._value);
      }
      
      public function cleanup() : void
      {
         _context.removeEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         cleanupGuiBase();
      }
      
      public function get spacing() : Number
      {
         return this._title.height;
      }
      
      public function initializeText(param1:String, param2:Number, param3:IGuiTransition) : void
      {
         this.title = this._title_initial;
         this.value = this._value_initial;
         this._title.x = -this._title.width + this._title.textWidth / 2;
         this._value.x = -this._value.textWidth / 2;
         x = param3.textAboveLocation.x;
         y = param3.textAboveLocation.y;
         this.setTitleText(param1);
         this.numValue = param2;
      }
      
      private function localeHandler(param1:GuiContextEvent) : void
      {
         this.setTitleText(this._title_loc_key);
         this.setValueText(this._displayedValue,this._value_loc_format);
      }
      
      public function setTitleText(param1:String, param2:TextField = null) : void
      {
         if(!param2)
         {
            param2 = this._title;
         }
         this._title_loc_key = param1;
         param2.htmlText = _context.locale.translateGui(param1);
         _context.locale.fixTextFieldFormat(param2);
      }
      
      public function setValueText(param1:Number, param2:String = null, param3:TextField = null) : void
      {
         if(!param3)
         {
            param3 = this._value;
         }
         if(!param2)
         {
            param3.htmlText = param1.toString();
            return;
         }
         this._value_loc_format = param2;
         var _loc4_:String = _context.locale.translateGui(param2);
         var _loc5_:RegExp = /{[[:blank:]]*value[[:blank:]]*}/gi;
         if(this.displayHours)
         {
            _loc4_ = _loc4_.replace(_loc5_,int(param1 * 24));
         }
         else
         {
            _loc4_ = _loc4_.replace(_loc5_,int(param1));
         }
         param3.htmlText = _loc4_;
         _context.locale.fixTextFieldFormat(param3);
      }
      
      public function set numValue(param1:Number) : void
      {
         this.updateNumValue(param1);
      }
      
      public function updateNumValue(param1:Number) : void
      {
         var _loc2_:int = Math.round(param1);
         this._numValue = _loc2_;
         if(param1 != this._displayedValue)
         {
            this._displayedValue = param1;
            this.setValueText(this._displayedValue);
         }
      }
      
      public function pulseValue(param1:Boolean) : void
      {
         TweenMax.killTweensOf(this._value);
         this._textPulseDuration = Math.max(this._textPulseDuration - 0.02,0.01);
         var _loc2_:Number = param1 ? 1.2 : 1;
         var _loc3_:Number = param1 ? 0.4 : this._textPulseDuration;
         TweenMax.fromTo(this._value,_loc3_,{
            "alpha":0.7,
            "scaleX":0.9,
            "scaleY":0.9
         },{
            "alpha":1,
            "scaleX":_loc2_,
            "scaleY":_loc2_,
            "ease":Back.easeOut
         });
         if(param1)
         {
            TweenMax.to(this._value,_loc3_,{
               "delay":_loc3_,
               "alpha":1,
               "scaleX":1,
               "scaleY":1,
               "ease":Back.easeOut
            });
         }
      }
      
      public function get numValue() : Number
      {
         return this._numValue;
      }
      
      public function get displayedValue() : int
      {
         return this._displayedValue;
      }
      
      public function get displayObject() : DisplayObject
      {
         return this;
      }
      
      public function update(param1:int) : void
      {
         var _loc2_:TallyTotalAnim = null;
         var _loc5_:int = 0;
         var _loc3_:int = 0;
         while(_loc3_ < this._anims.length)
         {
            _loc2_ = this._anims[_loc3_];
            _loc2_.update(param1);
            if(_loc2_.complete)
            {
               this._completeAnims.push(_loc2_);
            }
            _loc3_++;
         }
         var _loc4_:int = 0;
         while(_loc4_ < this._completeAnims.length)
         {
            _loc2_ = this._completeAnims[_loc4_];
            _loc5_ = this._anims.indexOf(_loc2_);
            if(_loc5_ > -1)
            {
               this._anims.splice(_loc5_,1);
            }
            _loc2_.doOnComplete();
            _loc4_++;
         }
         this._completeAnims.length = 0;
      }
      
      public function animateToSum(param1:TallyStep, param2:IGuiTransition, param3:Function) : void
      {
         this.title = this._title_final;
         this.value = this._value_final;
         this.setTitleText(param1.text);
         this.x = param2.textSumLocation.x + this.getXOffsetForTextAndValue(param1.text,param1.finalValue,this._title_final,this._value_final,this.displayHours ? HOURS_TEXT_FORMAT : DAYS_TEXT_FORMAT);
         this.y = param2.textSumLocation.y;
         param3(param1);
      }
      
      public function animateToTallyPoint(param1:TallyStep, param2:DisplayObject, param3:Function, param4:int = 333) : void
      {
         var _loc5_:int = 500;
         var _loc6_:TallyTotalAnim = new TallyTotalAnim(logger);
         _loc6_.target = this._title;
         _loc6_.x = -this._title.width - 5;
         _loc6_.y = 15;
         _loc6_.duration = _loc5_;
         _loc6_.delay = param4;
         this._anims.push(_loc6_);
         var _loc7_:TallyTotalAnim = new TallyTotalAnim(logger);
         _loc7_.target = this._value;
         _loc7_.x = 5;
         _loc7_.y = 0;
         _loc7_.duration = _loc5_;
         _loc7_.delay = param4;
         this._anims.push(_loc7_);
         var _loc8_:TallyTotalAnim = new TallyTotalAnim(logger);
         _loc8_.target = this;
         _loc8_.x = param2.x + this.getTextXOffset(this._title_tally,this._value_tally);
         _loc8_.y = param2.y;
         _loc8_.delay = param4;
         _loc8_.duration = _loc5_;
         _loc8_.onComplete = this.animToTallyPointComplete;
         _loc8_.onCompleteParams = [param3,param1];
         this._anims.push(_loc8_);
      }
      
      public function animToTallyPointComplete(param1:Function, param2:TallyStep) : void
      {
         this.value = this._value_tally;
         this.title = this._title_tally;
         param1(param2);
      }
      
      public function snapToFinalPoint(param1:int, param2:TallyStep, param3:DisplayObject) : void
      {
         this.setTitleToDays(param2);
         this.title = this._title_final;
         this.setValueToDays(param2.daysValue);
         this.value = this._value_final;
         this.scale = 0.85;
         this.y = param3.y + param1 * this.spacing * scale;
         this.x = param3.x + this.textXOffset;
      }
      
      public function animateToFinal(param1:int, param2:TallyStep, param3:DisplayObject, param4:Function = null, param5:int = 500) : void
      {
         this.setTitleToDays(param2);
         this.title = this._title_final;
         this.setValueToDays(param2.daysValue);
         this._displayedValue = param2.daysValue;
         this.value = this._value_final;
         var _loc6_:Number = 0.85;
         var _loc7_:Number = 0.33;
         var _loc8_:TallyTotalAnim = new TallyTotalAnim(logger);
         _loc8_.target = this;
         _loc8_.x = param3.x + this.textXOffset;
         _loc8_.y = param3.y + param1 * this.spacing * _loc6_;
         _loc8_.scale = _loc6_;
         _loc8_.delay = _loc7_;
         _loc8_.duration = param5;
         _loc8_.onComplete = param4;
         _loc8_.onCompleteParams = [param2];
         this._anims.push(_loc8_);
      }
      
      private function setTitleToDays(param1:TallyStep) : void
      {
         this.setTitleText(this.getDaysKey(param1.text));
      }
      
      private function getDaysKey(param1:String) : String
      {
         var _loc2_:* = param1 + "_days";
         var _loc3_:String = _context.locale.translateGui(_loc2_);
         if(_loc3_ == "{" + _loc2_ + "}")
         {
            return param1;
         }
         return _loc2_;
      }
      
      public function setValueToDays(param1:Number) : void
      {
         if(this.displayHours)
         {
            this.setValueText(param1,HOURS_TEXT_FORMAT);
         }
         else
         {
            this.setValueText(param1,DAYS_TEXT_FORMAT);
         }
      }
      
      public function get textXOffset() : Number
      {
         if(this._textOffset != 0)
         {
            return this._textOffset;
         }
         return this.curTextXOffset;
      }
      
      public function set textXOffset(param1:Number) : void
      {
         this._textOffset = param1;
      }
      
      public function setSumStepOffset() : void
      {
         this.textXOffset = this.getTextXOffset(this._title_final,this._value_final);
      }
      
      public function initTallyTextWidth(param1:Vector.<ITallyStep>) : Number
      {
         var _loc3_:TallyStep = null;
         var _loc4_:Number = NaN;
         if(!param1 || param1.length == 0)
         {
            this._textOffset = this.curTextXOffset;
         }
         this._textOffset = 0;
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            _loc3_ = param1[_loc2_] as TallyStep;
            if(!(!_loc3_ || _loc3_.isSum))
            {
               _loc4_ = this.getXOffsetForTextAndValue(this.getDaysKey(_loc3_.text),800,this._title_final,this._value_final,this.displayHours ? HOURS_TEXT_FORMAT : DAYS_TEXT_FORMAT);
               if(Math.abs(_loc4_) > Math.abs(this._textOffset))
               {
                  this._textOffset = _loc4_;
               }
            }
            _loc2_++;
         }
         return _loc4_;
      }
      
      public function getTextXOffset(param1:TextField, param2:TextField) : Number
      {
         if(param1 == null || param2 == null)
         {
            return 0;
         }
         var _loc3_:Number = param1.x + param1.width - param1.textWidth;
         var _loc4_:Number = param2.x + param2.textWidth;
         var _loc5_:Number = _loc4_ - _loc3_;
         return _loc5_ / 2 - _loc4_;
      }
      
      private function get curTextXOffset() : Number
      {
         return this.getTextXOffset(this.title,this.value);
      }
      
      private function getXOffsetForTextAndValue(param1:String, param2:Number, param3:TextField, param4:TextField, param5:String = null) : Number
      {
         if(param3 == null || param4 == null)
         {
            return 0;
         }
         var _loc6_:String = param3.htmlText;
         var _loc7_:String = param4.htmlText;
         this.setTitleText(this.getDaysKey(param1),param3);
         this.setValueText(param2,param5,param4);
         var _loc8_:Number = this.getTextXOffset(param3,param4);
         param3.htmlText = _loc6_;
         param4.htmlText = _loc7_;
         return _loc8_;
      }
   }
}

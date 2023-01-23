package game.gui
{
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleId;
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import engine.gui.GuiGpTextHelperFactory;
   import engine.gui.core.GuiSprite;
   import flash.display.MovieClip;
   import flash.geom.Rectangle;
   import flash.globalization.LocaleID;
   import flash.globalization.NumberFormatter;
   import flash.text.TextField;
   import flash.utils.getTimer;
   
   public class GameDownloadingSprite extends GuiSprite
   {
      
      public static var mcClazz:Class;
       
      
      private var gui:MovieClip;
      
      private var bulbsProgress:Vector.<MovieClip>;
      
      private var textProgress:TextField;
      
      private var textTitle:TextField;
      
      private var textBody:TextField;
      
      private var progressPercent:Number = 0;
      
      private var progressBytes:Number = 0;
      
      private var progressTarget:Number = 0;
      
      private var baselineBytes:Number = 0;
      
      private var startTime:int;
      
      private var progressBytesFormatter:NumberFormatter;
      
      private var originalGuiRect:Rectangle;
      
      private var str_progress:String;
      
      private var currentEstimate:Number = 0;
      
      private var lastEstimateUpdateTime:int;
      
      private var lastEtaMs:int = 0;
      
      private var ignoredEarlySamples:int;
      
      private var locale:Locale;
      
      private var hasBaseline:Boolean = false;
      
      private const NUM_IGNORED_SAMPLES:int = 5;
      
      private const TIME_ESTIMATE_SAMPLES:int = 50;
      
      private const MIN_START_PERCENT:Number = 0.05;
      
      private const ALPHA:Number = 0.1;
      
      private var logger:ILogger;
      
      public function GameDownloadingSprite(param1:ILogger, param2:LocaleId, param3:String, param4:String, param5:String)
      {
         var _loc8_:MovieClip = null;
         this.bulbsProgress = new Vector.<MovieClip>();
         this.startTime = getTimer();
         super();
         this.progressBytesFormatter = new NumberFormatter(LocaleID.DEFAULT);
         this.progressBytesFormatter.fractionalDigits = 3;
         this.progressBytesFormatter.leadingZero = true;
         this.progressBytesFormatter.trailingZeros = true;
         this.str_progress = !!param5 ? param5 : "{missing str_progress}";
         param4 = !!param4 ? param4 : "{missing str_body}";
         param3 = !!param3 ? param3 : "{missing str_title}";
         this.locale = new Locale(param2,new GuiGpTextHelperFactory(),param1);
         debugRender = 0;
         anchor.percentHeight = 100;
         anchor.percentWidth = 100;
         this.gui = new mcClazz() as MovieClip;
         addChild(this.gui);
         this.originalGuiRect = this.gui.getBounds(null);
         this.textProgress = this.gui.getChildByName("text_progress") as TextField;
         this.textTitle = this.gui.getChildByName("text_title") as TextField;
         this.textBody = this.gui.getChildByName("text_body") as TextField;
         if(!this.textProgress)
         {
            param1.error("GameDownloadingSprite no text_progress");
         }
         if(!this.textTitle)
         {
            param1.error("GameDownloadingSprite no text_title");
         }
         else
         {
            this.textTitle.htmlText = param3;
            this.locale.fixTextFieldFormat(this.textTitle);
         }
         if(!this.textBody)
         {
            param1.error("GameDownloadingSprite no text_body");
         }
         else
         {
            this.textBody.htmlText = param4;
            this.locale.fixTextFieldFormat(this.textBody);
         }
         var _loc6_:MovieClip = this.gui.getChildByName("progress") as MovieClip;
         if(!this.textProgress)
         {
            param1.error("GameDownloadingSprite no progress");
            return;
         }
         this.textProgress.htmlText = "";
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_.numChildren)
         {
            _loc8_ = _loc6_.getChildAt(_loc7_) as MovieClip;
            if(_loc8_)
            {
               this.bulbsProgress.push(_loc8_);
            }
            _loc7_++;
         }
         this.ignoredEarlySamples = 0;
         this.currentEstimate = 0;
         this.lastEtaMs = 0;
         this.lastEstimateUpdateTime = -500;
         this.hasBaseline = false;
         this.renderProgress();
      }
      
      private function renderProgress() : void
      {
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:Number = NaN;
         var _loc7_:int = 0;
         var _loc8_:String = null;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:MovieClip = null;
         if(this.textProgress)
         {
            _loc3_ = this.progressPercent * 100;
            _loc4_ = "??";
            _loc5_ = "??";
            _loc6_ = 0;
            _loc7_ = getTimer();
            if(this.ignoredEarlySamples > this.NUM_IGNORED_SAMPLES)
            {
               _loc11_ = _loc7_ - this.startTime;
               _loc12_ = 0;
               _loc13_ = 0;
               if(this.hasBaseline)
               {
                  _loc13_ = Math.max(0,Math.min(1,(this.progressBytes - this.baselineBytes) / (this.progressTarget - this.baselineBytes)));
               }
               if(_loc13_ > 0.00001)
               {
                  _loc12_ = _loc11_ / _loc13_;
                  this.currentEstimate += this.ALPHA * (_loc12_ - this.currentEstimate);
                  if(this.ignoredEarlySamples > this.TIME_ESTIMATE_SAMPLES || _loc13_ > this.MIN_START_PERCENT)
                  {
                     if(_loc7_ - this.lastEstimateUpdateTime > 500)
                     {
                        this.lastEstimateUpdateTime = _loc7_;
                        _loc6_ = this.currentEstimate - _loc11_;
                        _loc16_ = _loc6_ - this.lastEtaMs;
                        if(_loc16_ < 1500 && _loc16_ > -500)
                        {
                           _loc6_ = this.lastEtaMs;
                        }
                        else
                        {
                           this.lastEtaMs = _loc6_;
                        }
                     }
                     else
                     {
                        _loc6_ = this.lastEtaMs;
                     }
                     _loc14_ = _loc6_ / 1000;
                     _loc15_ = _loc14_ / 60;
                     _loc14_ -= _loc15_ * 60;
                     _loc4_ = _loc15_.toString();
                     _loc5_ = _loc14_.toString();
                  }
                  else
                  {
                     ++this.ignoredEarlySamples;
                  }
               }
            }
            else
            {
               ++this.ignoredEarlySamples;
            }
            _loc8_ = this.str_progress.replace("$PERCENT",_loc3_.toString());
            _loc8_ = _loc8_.replace("$ETA_MINUTES",StringUtil.padLeft(_loc4_,"0",2));
            _loc8_ = _loc8_.replace("$ETA_SECONDS",StringUtil.padLeft(_loc5_,"0",2));
            _loc9_ = this.progressBytes / 1000000000;
            _loc10_ = this.progressTarget / 1000000000;
            _loc8_ = _loc8_.replace("$DOWNLOAD_BYTES",this.progressBytesFormatter.formatNumber(_loc9_));
            _loc8_ = _loc8_.replace("$DOWNLOAD_TOTAL",this.progressBytesFormatter.formatNumber(_loc10_));
            this.textProgress.htmlText = _loc8_;
            this.locale.fixTextFieldFormat(this.textProgress);
         }
         var _loc1_:int = this.bulbsProgress.length * this.progressPercent;
         var _loc2_:int = 0;
         while(_loc2_ < this.bulbsProgress.length)
         {
            _loc17_ = this.bulbsProgress[_loc2_];
            _loc17_.visible = _loc2_ < _loc1_;
            _loc2_++;
         }
      }
      
      public function setProgressBytes(param1:Number, param2:Number) : void
      {
         this.progressBytes = param1;
         this.progressTarget = param2;
         if(!this.hasBaseline)
         {
            this.hasBaseline = true;
            this.baselineBytes = param1;
         }
         var _loc3_:Number = param1 / param2;
         this.progressPercent = Math.min(1,Math.max(0,_loc3_));
         this.renderProgress();
      }
      
      public function setProgressPercent(param1:Number) : void
      {
         this.progressPercent = Math.min(1,Math.max(0,param1));
         this.renderProgress();
      }
      
      override protected function resizeHandler() : void
      {
         super.resizeHandler();
         this.gui.x = width / 2;
         this.gui.y = height / 2;
         var _loc1_:Number = width / (this.originalGuiRect.width + 20);
         var _loc2_:Number = height / (this.originalGuiRect.height + 20);
         var _loc3_:Number = Math.min(2,Math.max(1,Math.min(_loc1_,_loc2_)));
         this.gui.scaleX = this.gui.scaleY = _loc3_;
      }
   }
}

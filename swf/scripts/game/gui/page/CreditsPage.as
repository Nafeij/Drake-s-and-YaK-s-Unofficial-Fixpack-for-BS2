package game.gui.page
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.KeyBindGroup;
   import engine.core.gp.GpControlButton;
   import engine.core.locale.Locale;
   import engine.core.util.StringUtil;
   import engine.gui.page.PageState;
   import engine.resource.BitmapResource;
   import engine.resource.CompressedTextResource;
   import engine.saga.Saga;
   import engine.saga.SagaCreditsDef;
   import engine.saga.SagaCreditsTextDef;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.ui.Keyboard;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   
   public class CreditsPage extends GamePage
   {
      
      private static var sectionClazzes:Vector.<Class>;
      
      public static var mcClazz:Class;
      
      public static var mcSection1Clazz:Class;
      
      public static var mcSection2Clazz:Class;
      
      public static var mcSection3Clazz:Class;
      
      public static var mcSectionBmpClazz:Class;
       
      
      private var flash_escape:Cmd;
      
      private var txtResources:Vector.<CompressedTextResource>;
      
      private var started:Boolean;
      
      private var gui:IGuiCredits;
      
      private var sections:Vector.<SectionData>;
      
      public var bmpLogoResource:BitmapResource;
      
      public var bmpBgResource:BitmapResource;
      
      private var _skippable:Boolean = true;
      
      public var imageUrls:Vector.<String>;
      
      public var scd:SagaCreditsDef;
      
      private var _creditsLoaded:Boolean;
      
      private var _setupText:Boolean;
      
      public var _end_titles:Boolean = false;
      
      public function CreditsPage(param1:SagaCreditsDef, param2:GameConfig, param3:Boolean)
      {
         this.flash_escape = new Cmd("credits_escape",this.cmdEscapeFunc);
         this.txtResources = new Vector.<CompressedTextResource>();
         this.sections = new Vector.<SectionData>();
         this.imageUrls = new Vector.<String>();
         super(param2,1920,1080);
         this.allowPageScaling = false;
         this.scd = param1;
         this.flash_escape.global = true;
         if(!sectionClazzes)
         {
            sectionClazzes = new Vector.<Class>();
            sectionClazzes.push(mcSection1Clazz);
            sectionClazzes.push(mcSection2Clazz);
            sectionClazzes.push(mcSection3Clazz);
         }
         this._skippable = param3;
      }
      
      override public function cleanup() : void
      {
         var _loc1_:SectionData = null;
         if(this.gui)
         {
            this.gui.removeEventListener(Event.COMPLETE,this.creditsCompleteHandler);
            this.gui.cleanup();
            this.gui = null;
         }
         if(this.sections)
         {
            for each(_loc1_ in this.sections)
            {
               _loc1_.cleanup();
            }
            this.sections = null;
         }
         this.txtResources = null;
         config.keybinder.unbind(this.flash_escape);
         config.gpbinder.unbind(this.flash_escape);
         this.flash_escape.cleanup();
         this.flash_escape = null;
         config.context.appInfo.setSystemIdleKeepAwake(false);
         super.cleanup();
      }
      
      override protected function handleStart() : void
      {
         var _loc5_:String = null;
         var _loc6_:CompressedTextResource = null;
         this.started = true;
         config.context.appInfo.setSystemIdleKeepAwake(true);
         mouseEnabled = true;
         setFullPageMovieClipClass(mcClazz);
         var _loc1_:Saga = config.saga;
         var _loc2_:String = _loc1_.locale.id.id;
         debugRender = this.scd.bgcolor;
         var _loc3_:SagaCreditsTextDef = this.scd.getLocaleTextDef(_loc2_);
         var _loc4_:String = _loc3_.logoUrl;
         for each(_loc5_ in _loc3_.textsUrls)
         {
            _loc6_ = getPageResource(_loc5_,CompressedTextResource) as CompressedTextResource;
            if(this.txtResources.indexOf(_loc6_) >= 0)
            {
               logger.error("CreditsPage duplicate credits url " + _loc5_);
               this.closeCredits(true);
               return;
            }
            this.txtResources.push(_loc6_);
         }
         if(!this.txtResources.length)
         {
            logger.error("CreditsPage no text urls for " + _loc2_);
            this.closeCredits(true);
            return;
         }
         this.bmpLogoResource = !!_loc4_ ? getPageResource(_loc4_,BitmapResource) as BitmapResource : null;
         this.bmpBgResource = !!this.scd.bgurl ? getPageResource(this.scd.bgurl,BitmapResource) as BitmapResource : null;
         if(this._skippable)
         {
            config.keybinder.bind(false,false,false,Keyboard.ESCAPE,this.flash_escape,KeyBindGroup.CREDITS);
            config.keybinder.bind(false,false,false,Keyboard.BACK,this.flash_escape,KeyBindGroup.CREDITS);
            config.gpbinder.bindPress(GpControlButton.B,this.flash_escape,KeyBindGroup.CREDITS);
         }
         this.loadImages();
      }
      
      private function loadImages() : void
      {
         var _loc2_:String = null;
         var _loc1_:Saga = config.saga;
         this.scd.fetchImageList(_loc1_,this.imageUrls,logger);
         for each(_loc2_ in this.imageUrls)
         {
            if(_loc2_.indexOf("logic:") != 0)
            {
               getPageResource(_loc2_,BitmapResource);
            }
         }
      }
      
      override protected function handleLoaded() : void
      {
         var _loc2_:CompressedTextResource = null;
         var _loc3_:Saga = null;
         if(this._creditsLoaded)
         {
            return;
         }
         super.handleLoaded();
         if(Boolean(fullScreenMc) && !this.gui)
         {
            fullScreenMc.x = 0;
            fullScreenMc.y = 0;
            this.gui = fullScreenMc as IGuiCredits;
            this.gui.init(config.gameGuiContext,this,!!this.bmpLogoResource ? this.bmpLogoResource.bmp : null);
            this.gui.addEventListener(Event.COMPLETE,this.creditsCompleteHandler);
            _loc3_ = config.saga;
            this.gui.textColor = this.scd.textcolor;
            this.gui.headerColor = this.scd.headercolor;
            this.gui.imageSpeed = this.scd.imagespeed;
            this.resizeHandler();
         }
         var _loc1_:* = "";
         for each(_loc2_ in this.txtResources)
         {
            if(_loc2_)
            {
               if(_loc2_.ok)
               {
                  if(_loc1_)
                  {
                     _loc1_ += "\n";
                  }
                  _loc1_ += _loc2_.text;
               }
               else
               {
                  logger.error("Credits page failed to load " + _loc2_);
               }
               releasePageResource(_loc2_.url);
            }
         }
         if(Boolean(this.bmpBgResource) && this.bmpBgResource.ok)
         {
            this.gui.setBackgroundBitmapdata(this.bmpBgResource.bitmapData);
         }
         this.setupText(_loc1_);
         this.txtResources = null;
         this.layoutImages();
         this._creditsLoaded = true;
      }
      
      private function layoutImages() : void
      {
         var _loc2_:String = null;
         var _loc3_:BitmapResource = null;
         var _loc4_:int = 0;
         var _loc1_:Saga = config.saga;
         for each(_loc2_ in this.imageUrls)
         {
            if(StringUtil.startsWith(_loc2_,"logic:"))
            {
               if(StringUtil.startsWith(_loc2_,"logic:pad="))
               {
                  _loc4_ = int(_loc2_.substring("logic:pad=".length));
                  this.gui.addAlternatingImagePad(_loc4_);
               }
               else
               {
                  logger.error("invalid credits logic [" + _loc2_ + "]");
               }
            }
            else
            {
               _loc3_ = getPageResource(_loc2_,BitmapResource) as BitmapResource;
               if(_loc3_)
               {
                  this.gui.addAlternatingImage(_loc3_.bitmapData,this.scd.imagecolor);
               }
            }
         }
      }
      
      override protected function handleButtonClosePress() : void
      {
         this.closeCredits(true);
      }
      
      override protected function handleTap() : void
      {
         if(this._skippable)
         {
            showButtonClose(3);
         }
      }
      
      private function setupText(param1:String) : void
      {
         var lines:Array;
         var sn:int;
         var section:SectionData = null;
         var config:GuiCreditsSectionConfig = null;
         var lineNum:int = 0;
         var line:String = null;
         var hd:String = null;
         var pipe:int = 0;
         var clazz:Class = null;
         var smc:MovieClip = null;
         var raw:String = param1;
         var locale:Locale = this.config.context.locale;
         if(locale.info.deIcelandic)
         {
            raw = locale.deIce(raw);
         }
         lines = raw.split("\n");
         sn = 0;
         lineNum = 0;
         for each(line in lines)
         {
            lineNum++;
            if(line.length != 0)
            {
               if(line.charAt(0) == "\t")
               {
                  if(line.length == 1)
                  {
                     continue;
                  }
                  if(section)
                  {
                     section.addBody(line.substr(1) + "\n");
                     if(!section.isFull)
                     {
                        continue;
                     }
                     hd = null;
                  }
               }
               else
               {
                  pipe = line.indexOf("|");
                  if(pipe > 0)
                  {
                     config = new GuiCreditsSectionConfig().decode(line.substr(0,pipe));
                     if(line.length > pipe + 1)
                     {
                        hd = line.substr(pipe + 1);
                     }
                     else
                     {
                        hd = null;
                     }
                  }
               }
               try
               {
                  section = new SectionData(config,hd);
                  this.sections.push(section);
               }
               catch(err:Error)
               {
                  logger.error("Failure parsing credits at line " + lineNum + ":[" + line + "]: " + err);
                  break;
               }
            }
         }
         if(this.gui)
         {
            for each(section in this.sections)
            {
               if(section.config.isbmp)
               {
                  smc = new mcSectionBmpClazz() as MovieClip;
                  this.gui.addSectionBitmap(smc,section.header,section.bodies[0]);
                  continue;
               }
               clazz = sectionClazzes[section.config.cols - 1];
               smc = new clazz() as MovieClip;
               switch(section.config.cols)
               {
                  case 1:
                     this.gui.addSection1(smc,section.header,section.bodies[0]);
                     break;
                  case 2:
                     this.gui.addSection2(section.config,smc,section.header,section.bodies[0],section.bodies[1]);
                     break;
                  case 3:
                     this.gui.addSection3(smc,section.header,section.bodies[0],section.bodies[1],section.bodies[2]);
                     break;
               }
            }
            this.gui.layoutCredits(width,height);
            this.gui.rollCredits();
         }
      }
      
      private function cmdEscapeFunc(param1:CmdExec) : void
      {
         this.closeCredits();
      }
      
      private function closeCredits(param1:Boolean = false) : void
      {
         var _loc2_:Saga = null;
         var _loc3_:ScenePage = null;
         if(this._skippable || param1)
         {
            if(this._end_titles)
            {
               _loc3_ = config.pageManager.currentPage as ScenePage;
               if(_loc3_)
               {
                  _loc3_.wipeOutDuration = 0;
               }
               this.state = PageState.LOADING;
               this.percentLoaded = 0;
               config.saga.showStartPage(false);
               config.pageManager.hideCreditsPage();
            }
            else
            {
               config.pageManager.hideCreditsPage();
            }
            _loc2_ = Saga.instance;
            if(_loc2_)
            {
               _loc2_.triggerCreditsComplete();
            }
         }
      }
      
      override protected function resizeHandler() : void
      {
         super.resizeHandler();
         if(this.gui)
         {
            this.gui.layoutCredits(width,height);
         }
      }
      
      private function creditsCompleteHandler(param1:Event) : void
      {
         this.closeCredits(true);
      }
      
      override public function update(param1:int) : void
      {
         if(this.gui)
         {
            this.gui.update(param1);
         }
      }
      
      public function get skippable() : Boolean
      {
         return this._skippable;
      }
   }
}

import game.gui.page.GuiCreditsSectionConfig;

class SectionData
{
    
   
   public var header:String;
   
   public var bodies:Vector.<String>;
   
   private var index:int = 0;
   
   public var config:GuiCreditsSectionConfig;
   
   private var count:int;
   
   private const MAX_ROWS:int = 30;
   
   public function SectionData(param1:GuiCreditsSectionConfig, param2:String)
   {
      this.bodies = new Vector.<String>();
      super();
      this.config = param1;
      if(param1.cols < 1 || param1.cols > 3)
      {
         throw new ArgumentError("Unsupported columns: " + param1.cols);
      }
      this.header = param2;
      var _loc3_:int = 0;
      while(_loc3_ < param1.cols)
      {
         this.bodies.push("");
         _loc3_++;
      }
   }
   
   public function cleanup() : void
   {
      this.bodies = null;
      this.header = null;
   }
   
   public function addBody(param1:String) : void
   {
      this.bodies[this.index] += param1;
      this.index = (this.index + 1) % this.config.cols;
      ++this.count;
   }
   
   public function get isFull() : Boolean
   {
      return this.count / this.config.cols >= this.MAX_ROWS;
   }
}

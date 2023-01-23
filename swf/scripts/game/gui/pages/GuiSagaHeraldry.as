package game.gui.pages
{
   import com.adobe.crypto.MD5;
   import com.greensock.TweenMax;
   import com.stoicstudio.platform.PlatformInput;
   import engine.automator.EngineAutomator;
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.render.Camera;
   import engine.core.util.StringUtil;
   import engine.gui.GuiContextEvent;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpAlignH;
   import engine.gui.GuiGpAlignV;
   import engine.gui.GuiGpBitmap;
   import engine.gui.GuiGpNav;
   import engine.heraldry.Heraldry;
   import engine.heraldry.HeraldryDef;
   import engine.heraldry.HeraldryLoader;
   import engine.heraldry.HeraldrySystem;
   import engine.resource.ResourceManager;
   import engine.saga.ISagaExpression;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.TimerEvent;
   import flash.geom.Rectangle;
   import flash.system.System;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   import game.gui.page.IGuiSagaHeraldry;
   
   public class GuiSagaHeraldry extends GuiBase implements IGuiSagaHeraldry
   {
      
      public static var MAX_HERALDRY_BYTES:int = 400 * (1024 * 1024);
      
      private static const MAX_LOADING_COUNT:int = 30;
      
      private static const MAX_START_LOAD_COUNT:int = 5;
       
      
      public var _tilesHolder:MovieClip;
      
      public var _placeholder_flag:MovieClip;
      
      public var _text_page_number:TextField;
      
      public var _text$search_crests:TextField;
      
      public var _button_close:ButtonWithIndex;
      
      public var _button_prev:ButtonWithIndex;
      
      public var _button_next:ButtonWithIndex;
      
      public var _button$confirm:ButtonWithIndex;
      
      public var _button$animals:ButtonWithIndex;
      
      public var _button$weapons:ButtonWithIndex;
      
      public var _button$objects:ButtonWithIndex;
      
      public var _button$people:ButtonWithIndex;
      
      public var _button$misc:ButtonWithIndex;
      
      public var _button$all:ButtonWithIndex;
      
      public var _text_input_search_crests:TextField;
      
      public var _spinner:MovieClip;
      
      public var _text$ks_crest_thanks:TextField;
      
      public var _search_background:MovieClip;
      
      public var filterButtons:Array;
      
      public var placeholder_flags_rect:Rectangle;
      
      private var _system:HeraldrySystem;
      
      private var currentFilterTags:int = 16777215;
      
      private var resman:ResourceManager;
      
      private var tiles:Vector.<GuiSagaHeraldryTile>;
      
      private var _selectedLoader:HeraldryLoader;
      
      private var selectedFlagBitmap:Bitmap;
      
      private var defs:Vector.<HeraldryDef>;
      
      private var scrollCursor:int = 0;
      
      private var spinner_rotate:MovieClip;
      
      private var loaders:Dictionary;
      
      private var gplayer:int;
      
      private var gp_b:GuiGpBitmap;
      
      private var gp_y:GuiGpBitmap;
      
      private var gp_a:GuiGpBitmap;
      
      private var gp_l1:GuiGpBitmap;
      
      private var gp_r1:GuiGpBitmap;
      
      private var nav:GuiGpNav;
      
      private var filterNav:GuiGpNav;
      
      private var cmd_b:Cmd;
      
      private var cmd_y:Cmd;
      
      private var cmd_l1:Cmd;
      
      private var cmd_r1:Cmd;
      
      private var _overlayShowing:Boolean = false;
      
      private var searchTimer:Timer;
      
      private var unusedLoaders:Dictionary;
      
      private var loaderCursor:int = 0;
      
      private var loaderCompletionWait:int = 0;
      
      private var loaderTimer:Timer;
      
      private var loading_count:int;
      
      private var buttonTagNames:Dictionary;
      
      private var filterGplayer:int;
      
      public function GuiSagaHeraldry()
      {
         this.filterButtons = [];
         this.tiles = new Vector.<GuiSagaHeraldryTile>();
         this.selectedFlagBitmap = new Bitmap();
         this.loaders = new Dictionary();
         this.gp_b = GuiGp.ctorPrimaryBitmap(GpControlButton.B);
         this.gp_y = GuiGp.ctorPrimaryBitmap(GpControlButton.Y,true);
         this.gp_a = GuiGp.ctorPrimaryBitmap(GpControlButton.A,true);
         this.gp_l1 = GuiGp.ctorPrimaryBitmap(GpControlButton.L1,true);
         this.gp_r1 = GuiGp.ctorPrimaryBitmap(GpControlButton.R1,true);
         this.cmd_b = new Cmd("cmd_heraldry_b",this.cmdfunc_b);
         this.cmd_y = new Cmd("cmd_heraldry_b",this.cmdfunc_y);
         this.cmd_l1 = new Cmd("cmd_heraldry_b",this.cmdfunc_l1);
         this.cmd_r1 = new Cmd("cmd_heraldry_b",this.cmdfunc_r1);
         this.searchTimer = new Timer(1000,1);
         this.unusedLoaders = new Dictionary();
         this.loaderTimer = new Timer(10,0);
         this.buttonTagNames = new Dictionary();
         super();
         this.cmd_b.global = true;
         this.cmd_y.global = true;
         this.gp_b.scale = this.gp_y.scale = this.gp_a.scale = this.gp_l1.scale = this.gp_r1.scale = 1.5;
         addChild(this.gp_b);
         addChild(this.gp_a);
         addChild(this.gp_l1);
         addChild(this.gp_r1);
         if(!HeraldrySystem.SUPPRESS_ADDITIONAL_HERALDRY)
         {
            addChild(this.gp_y);
         }
      }
      
      public function init(param1:IGuiContext, param2:ResourceManager) : void
      {
         var _loc4_:GuiSagaHeraldryTile = null;
         super.initGuiBase(param1);
         this._spinner = requireGuiChild("spinner") as MovieClip;
         this._tilesHolder = requireGuiChild("tilesHolder") as MovieClip;
         this._placeholder_flag = requireGuiChild("placeholder_flag") as MovieClip;
         this._text_page_number = requireGuiChild("text_page_number") as TextField;
         this._text$search_crests = requireGuiChild("text$search_crests") as TextField;
         this._search_background = requireGuiChild("search_box_background") as MovieClip;
         this._button_close = requireGuiChild("button_close") as ButtonWithIndex;
         this._button_prev = requireGuiChild("button_prev") as ButtonWithIndex;
         this._button_next = requireGuiChild("button_next") as ButtonWithIndex;
         this._button$confirm = requireGuiChild("button$confirm") as ButtonWithIndex;
         this._button$animals = requireGuiChild("button$animals") as ButtonWithIndex;
         this._button$weapons = requireGuiChild("button$weapons") as ButtonWithIndex;
         this._button$objects = requireGuiChild("button$objects") as ButtonWithIndex;
         this._button$people = requireGuiChild("button$people") as ButtonWithIndex;
         this._button$misc = requireGuiChild("button$misc") as ButtonWithIndex;
         this._button$all = requireGuiChild("button$all") as ButtonWithIndex;
         this._text_input_search_crests = requireGuiChild("text_input_search_crests") as TextField;
         this._text$ks_crest_thanks = requireGuiChild("text$ks_crest_thanks") as TextField;
         this._text$ks_crest_thanks.mouseEnabled = this._text$ks_crest_thanks.selectable = false;
         registerScalableTextfield(this._text$ks_crest_thanks);
         this._button_close.guiButtonContext = param1;
         this._button_prev.guiButtonContext = param1;
         this._button_next.guiButtonContext = param1;
         this._button$confirm.guiButtonContext = param1;
         this._button$animals.guiButtonContext = param1;
         this._button$weapons.guiButtonContext = param1;
         this._button$objects.guiButtonContext = param1;
         this._button$people.guiButtonContext = param1;
         this._button$misc.guiButtonContext = param1;
         this._button$all.guiButtonContext = param1;
         this.resman = param2;
         this._placeholder_flag.graphics.clear();
         if(this._placeholder_flag.numChildren)
         {
            this._placeholder_flag.removeChildren(0,this._placeholder_flag.numChildren - 1);
         }
         this._placeholder_flag.addChild(this.selectedFlagBitmap);
         this._text_page_number.mouseEnabled = false;
         this._text_page_number.text = "";
         this._text$search_crests.mouseEnabled = false;
         this._text_input_search_crests.text = "";
         registerScalableTextfield(this._text$search_crests);
         this._text_input_search_crests.addEventListener(Event.CHANGE,this.textChangeHandler);
         this._text_input_search_crests.addEventListener(FocusEvent.FOCUS_IN,this.searchFocusInHandler);
         this._text_input_search_crests.addEventListener(FocusEvent.FOCUS_OUT,this.searchFocusOutHandler);
         this._button_close.setDownFunction(this.buttonCloseHandler);
         this._button_prev.setDownFunction(this.buttonPrevHandler);
         this._button_next.setDownFunction(this.buttonNextHandler);
         if(HeraldrySystem.SUPPRESS_ADDITIONAL_HERALDRY)
         {
            this._button$animals.visible = false;
            this._button$weapons.visible = false;
            this._button$objects.visible = false;
            this._button$people.visible = false;
            this._button$misc.visible = false;
            this._button$all.visible = false;
            this._text_input_search_crests.visible = false;
            this._text$search_crests.visible = false;
         }
         else
         {
            this.filterNav = new GuiGpNav(param1,"heraldry_filt",this);
            this.filterNav.alwaysHintNav = true;
            this.filterNav.pressOnNavigate = true;
            this.filterNav.scale = 1.5;
            this.filterNav.setAlignNavDefault(GuiGpAlignH.C,GuiGpAlignV.N_UP);
            this.filterNav.add(this._button$animals);
            this.filterNav.add(this._button$weapons);
            this.filterNav.add(this._button$objects);
            this.filterNav.add(this._button$people);
            this.filterNav.add(this._button$misc);
            this.filterNav.add(this._button$all);
            this.filterNav.setShowControl(this._button$animals,false);
            this.filterNav.setShowControl(this._button$weapons,false);
            this.filterNav.setShowControl(this._button$objects,false);
            this.filterNav.setShowControl(this._button$people,false);
            this.filterNav.setShowControl(this._button$misc,false);
            this.filterNav.setShowControl(this._button$all,false);
            this.filterNav.selected = this._button$all;
            this.addFilterButton(this._button$animals);
            this.addFilterButton(this._button$weapons);
            this.addFilterButton(this._button$objects);
            this.addFilterButton(this._button$people);
            this.addFilterButton(this._button$misc);
            this.addFilterButton(this._button$all);
         }
         this._button_close.visible = PlatformInput.hasClicker;
         this._button$confirm.guiButtonContext = _context;
         this._button$confirm.enabled = false;
         this.buttonFilterHandler(this._button$all);
         this.searchTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.searchTimerHandler);
         this._search_background.visible = this._text_input_search_crests.visible;
         this._spinner.visible = false;
         this.spinner_rotate = this._spinner.getChildByName("spinner_rotate") as MovieClip;
         var _loc3_:int = 0;
         while(_loc3_ < this._tilesHolder.numChildren)
         {
            _loc4_ = this._tilesHolder.getChildAt(_loc3_) as GuiSagaHeraldryTile;
            this.tiles.push(_loc4_);
            _loc4_.init(param1);
            _loc4_.setDownFunction(this.tileHandler);
            _loc4_.isToggle = true;
            _loc4_.canToggleUp = false;
            _loc3_++;
         }
         this.loaderTimer.addEventListener(TimerEvent.TIMER,this.loaderTimerHander);
         this._button$confirm.setDownFunction(this.buttonConfirmHandler);
         PlatformInput.dispatcher.addEventListener(PlatformInput.EVENT_LAST_INPUT,this.platformInputHandler);
         this.platformInputHandler(null);
      }
      
      private function platformInputHandler(param1:Event) : void
      {
         this._text$search_crests.visible = PlatformInput.hasKeyboard && this._text_input_search_crests.visible;
      }
      
      private function buttonConfirmHandler(param1:ButtonWithIndex) : void
      {
         if(!this._selectedLoader || !this._selectedLoader.heraldry || !this._system)
         {
            return;
         }
         this._system.selectedHeraldry = this._selectedLoader.heraldry.clone();
         dispatchEvent(new Event(Event.CLOSE));
      }
      
      private function tileHandler(param1:GuiSagaHeraldryTile) : void
      {
         var _loc2_:GuiSagaHeraldryTile = null;
         for each(_loc2_ in this.tiles)
         {
            _loc2_.toggled = param1 == _loc2_;
            if(_loc2_.toggled)
            {
               this.selectedLoader = _loc2_.loader;
            }
         }
      }
      
      private function searchTimerHandler(param1:TimerEvent) : void
      {
         this.doSearch();
      }
      
      private function textChangeHandler(param1:Event) : void
      {
         this.searchTimer.reset();
         this.searchTimer.start();
      }
      
      private function searchFocusInHandler(param1:FocusEvent) : void
      {
         this._text$search_crests.visible = false;
      }
      
      private function searchFocusOutHandler(param1:FocusEvent) : void
      {
         this._text$search_crests.visible = !this._text_input_search_crests.text && this._text$search_crests.visible;
      }
      
      private function doSearch() : void
      {
         var _loc1_:RegExp = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:uint = 0;
         this.searchTimer.stop();
         if(!this._system)
         {
            return;
         }
         if(this._text_input_search_crests.text)
         {
            _loc3_ = this._text_input_search_crests.text;
            _loc4_ = MD5.hash(_loc3_);
            _loc1_ = new RegExp(_loc4_);
         }
         if(HeraldrySystem.platformHeraldryExcludes.length > 0)
         {
            _context.logger.i("Heraldry","Excluding platform heraldry from additional json...");
            for each(_loc5_ in HeraldrySystem.platformHeraldryExcludes)
            {
               _loc6_ = uint(this._system.tagsBitByName[_loc5_]);
               if(_loc6_)
               {
                  this.currentFilterTags ^= _loc6_;
               }
            }
         }
         var _loc2_:ISagaExpression = _context.saga.expression;
         this.defs = this._system.getHeraldryDefs(_loc1_,this.currentFilterTags,_loc2_);
         this.scrollCursor = 0;
         this.renderHeraldries();
      }
      
      private function clearTiles() : void
      {
         var _loc1_:GuiSagaHeraldryTile = null;
         for each(_loc1_ in this.tiles)
         {
            if(Boolean(this._selectedLoader) && this._selectedLoader == _loc1_.loader)
            {
               this.selectedLoader = null;
            }
            if(_loc1_.loader)
            {
               _loc1_.loader.removeEventListener(Event.COMPLETE,this.loaderCompleteHandler);
            }
            _loc1_.loader = null;
            _loc1_.toggled = false;
         }
      }
      
      private function renderHeraldries() : void
      {
         var _loc4_:HeraldryLoader = null;
         var _loc5_:Object = null;
         var _loc6_:HeraldryDef = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:GuiSagaHeraldryTile = null;
         this.clearTiles();
         if(!this.defs)
         {
            return;
         }
         var _loc1_:int = Math.ceil(this.defs.length / this.tiles.length);
         this._text_page_number.text = (this.scrollCursor + 1).toString() + "/" + _loc1_;
         var _loc2_:* = _loc1_ > 1;
         this._text_page_number.visible = _loc2_;
         this._button_next.visible = this._button_prev.visible = _loc2_;
         this.gp_l1.visible = this.gp_r1.visible = _loc2_;
         var _loc3_:int = this.scrollCursor * this.tiles.length;
         this.loaderCursor = 0;
         this.loaderCompletionWait = 0;
         this.unusedLoaders = new Dictionary();
         for each(_loc4_ in this.loaders)
         {
            this.unusedLoaders[_loc4_] = _loc4_;
         }
         _loc7_ = 0;
         _loc8_ = _loc3_;
         while(_loc8_ < this.defs.length)
         {
            _loc6_ = this.defs[_loc8_];
            if(_loc7_ >= this.tiles.length)
            {
               break;
            }
            _loc4_ = this.loaders[_loc6_];
            if(!_loc4_)
            {
               _loc4_ = new HeraldryLoader(this.resman,_loc6_,this._system);
               this.loaders[_loc6_] = _loc4_;
               ++this.loaderCompletionWait;
            }
            delete this.unusedLoaders[_loc4_];
            _loc9_ = this.getTile(_loc7_);
            _loc9_.loader = _loc4_;
            _loc7_++;
            _loc8_++;
         }
         this.purgeUnusedLoaders();
         while(_loc7_ < this.tiles.length)
         {
            this.getTile(_loc7_).loader = null;
            _loc7_++;
         }
         if(this.loaderCompletionWait)
         {
            this.showSpinner();
         }
         else
         {
            this.hideSpinner();
         }
         this.loaderTimer.reset();
         this.loaderTimer.start();
      }
      
      private function purgeUnusedLoaders() : void
      {
         var _loc1_:HeraldryLoader = null;
         var _loc2_:int = 0;
         for each(_loc1_ in this.unusedLoaders)
         {
            _loc2_ = System.privateMemory;
            if(_loc2_ <= MAX_HERALDRY_BYTES)
            {
               break;
            }
            delete this.loaders[_loc1_.def];
            _loc1_.cleanup();
         }
      }
      
      private function loaderTimerHander(param1:TimerEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:GuiSagaHeraldryTile = null;
         while(this.loaderCursor < this.tiles.length)
         {
            _loc3_ = this.tiles[this.loaderCursor];
            ++this.loaderCursor;
            if(!_loc3_.loader)
            {
               break;
            }
            if(!_loc3_.loader.loading)
            {
               if(!_loc3_.loader.heraldry)
               {
                  _loc3_.loader.addEventListener(Event.COMPLETE,this.loaderCompleteHandler);
                  ++this.loading_count;
                  _loc2_++;
                  _loc3_.loader.loadHeraldry();
               }
            }
            if(this.loading_count > MAX_LOADING_COUNT || _loc2_ > MAX_START_LOAD_COUNT)
            {
               return;
            }
         }
         this.loaderTimer.stop();
      }
      
      private function loaderCompleteHandler(param1:Event) : void
      {
         var _loc2_:HeraldryLoader = param1.target as HeraldryLoader;
         _loc2_.removeEventListener(Event.COMPLETE,this.loaderCompleteHandler);
         --this.loading_count;
         --this.loaderCompletionWait;
         if(this.loaderCompletionWait <= 0)
         {
            this.hideSpinner();
         }
      }
      
      private function getTile(param1:int) : GuiSagaHeraldryTile
      {
         return this.tiles[param1];
      }
      
      public function showGuiHeraldry(param1:HeraldrySystem) : void
      {
         this._system = param1;
         this.visible = true;
         if(this._system)
         {
            this.showSelectedHeraldry(this._system.selectedHeraldry);
         }
         this._text$ks_crest_thanks.visible = Boolean(this._system) && Boolean(this._system.additionalUrl);
         _context.addEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         this.localeHandler(null);
         this.gplayer = GpBinder.gpbinder.createLayer("GuiSagaHeraldry");
         this.gp_b.gplayer = this.gp_a.gplayer = this.gp_r1.gplayer = this.gp_l1.gplayer = this.gp_y.gplayer = this.gplayer;
         Camera.ALLOW_ZOOM = false;
         GpBinder.gpbinder.bindPress(GpControlButton.B,this.cmd_b);
         GpBinder.gpbinder.bindPress(GpControlButton.Y,this.cmd_y);
         GpBinder.gpbinder.bindPress(GpControlButton.R1,this.cmd_r1);
         GpBinder.gpbinder.bindPress(GpControlButton.L1,this.cmd_l1);
         GuiGp.placeIconRight(this._button_close,this.gp_b);
         GuiGp.placeIconRight(this._button$confirm,this.gp_a);
         GuiGp.placeIconTop(this._button_prev,this.gp_l1,null,GuiGpAlignV.N_UP);
         GuiGp.placeIconBottom(this._button_next,this.gp_r1,GuiGpAlignV.S_DOWN,null);
         GuiGp.placeIconBottom(this._button$animals,this.gp_y,GuiGpAlignV.S_DOWN,null);
         this.gp_y.createCaption(context,GuiGpBitmap.CAPTION_RIGHT);
         this.gp_y.caption.setToken("heraldry_filters");
         this.gp_y.updateCaptionPlacement();
         this.createNav();
         this._text_input_search_crests.visible = PlatformInput.hasKeyboard && !HeraldrySystem.SUPPRESS_ADDITIONAL_HERALDRY;
         this._text$search_crests.visible = !this._text_input_search_crests.text && this._text_input_search_crests.visible;
         this._search_background.visible = this._text_input_search_crests.visible;
         this.doSearch();
         EngineAutomator.notify("gui_saga_heraldry_ready");
      }
      
      private function localeHandler(param1:GuiContextEvent) : void
      {
         scaleTextfields();
      }
      
      public function hideGuiHeraldry() : void
      {
         var _loc1_:HeraldryLoader = null;
         _context.removeEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         this.selectedLoader = null;
         this.clearTiles();
         for each(_loc1_ in this.loaders)
         {
            _loc1_.cleanup();
         }
         this.loaders = new Dictionary();
         this._system = null;
         this.visible = false;
         GpBinder.gpbinder.removeLayer(this.gplayer);
         this.gplayer = 0;
         Camera.ALLOW_ZOOM = true;
         if(this.nav)
         {
            this.nav.cleanup();
            this.nav = null;
         }
         GpBinder.gpbinder.unbind(this.cmd_b);
         GpBinder.gpbinder.unbind(this.cmd_y);
         GpBinder.gpbinder.unbind(this.cmd_r1);
         GpBinder.gpbinder.unbind(this.cmd_l1);
      }
      
      public function cleanup() : void
      {
         this._button_close.cleanup();
         this._button_prev.cleanup();
         this._button_next.cleanup();
         this._button$confirm.cleanup();
         this._button$animals.cleanup();
         this._button$weapons.cleanup();
         this._button$objects.cleanup();
         this._button$people.cleanup();
         this._button$misc.cleanup();
         this._button$all.cleanup();
         this.selectedLoader = null;
         this.clearTiles();
         this.hideGuiHeraldry();
         this.cmd_b.cleanup();
         this.cmd_y.cleanup();
         this.cmd_r1.cleanup();
         this.cmd_l1.cleanup();
         GuiGp.releasePrimaryBitmap(this.gp_a);
         GuiGp.releasePrimaryBitmap(this.gp_b);
         GuiGp.releasePrimaryBitmap(this.gp_y);
         GuiGp.releasePrimaryBitmap(this.gp_l1);
         GuiGp.releasePrimaryBitmap(this.gp_r1);
      }
      
      private function addFilterButton(param1:ButtonWithIndex) : void
      {
         this.filterButtons.push(param1);
         param1.setDownFunction(this.buttonFilterHandler);
         param1.isToggle = true;
         param1.canToggleUp = false;
         var _loc2_:String = StringUtil.stripPrefix(param1.name,"button$");
         if(_loc2_ != "all")
         {
            this.buttonTagNames[param1] = _loc2_;
         }
         else
         {
            this.buttonTagNames[param1] = null;
            param1.toggled = true;
         }
      }
      
      private function buttonFilterHandler(param1:ButtonWithIndex) : void
      {
         var _loc2_:ButtonWithIndex = null;
         var _loc3_:String = null;
         var _loc4_:int = 0;
         if(!this._system)
         {
            return;
         }
         for each(_loc2_ in this.filterButtons)
         {
            _loc2_.toggled = param1 == _loc2_;
            if(_loc2_.toggled)
            {
               _loc3_ = this.buttonTagNames[_loc2_];
               _loc4_ = 16777215;
               if(_loc3_)
               {
                  _loc4_ = int(this._system.tagsBitByName[_loc3_]);
               }
               this.currentFilterTags = _loc4_;
            }
            else
            {
               _loc2_.setHovering(false);
            }
         }
         this.doSearch();
      }
      
      private function buttonCloseHandler(param1:ButtonWithIndex) : void
      {
         dispatchEvent(new Event(Event.CLOSE));
      }
      
      private function buttonPrevHandler(param1:ButtonWithIndex) : void
      {
         if(!this.defs)
         {
            return;
         }
         if(this.scrollCursor <= 0)
         {
            return;
         }
         this.scrollCursor = Math.max(0,this.scrollCursor - 1);
         this.renderHeraldries();
      }
      
      private function buttonNextHandler(param1:ButtonWithIndex) : void
      {
         if(!this.defs)
         {
            return;
         }
         var _loc2_:int = Math.floor(this.defs.length / this.tiles.length);
         if(this.scrollCursor >= _loc2_)
         {
            return;
         }
         this.scrollCursor = Math.min(_loc2_,this.scrollCursor + 1);
         this.renderHeraldries();
      }
      
      private function set system(param1:HeraldrySystem) : void
      {
         this._system = param1;
      }
      
      private function get system() : HeraldrySystem
      {
         return this._system;
      }
      
      public function get selectedLoader() : HeraldryLoader
      {
         return this._selectedLoader;
      }
      
      public function set selectedLoader(param1:HeraldryLoader) : void
      {
         if(this._selectedLoader == param1)
         {
            return;
         }
         if(this._selectedLoader)
         {
            this._selectedLoader.removeEventListener(Event.COMPLETE,this.selectedLoaderHandler);
         }
         this._selectedLoader = param1;
         if(this._system && this._system.selectedHeraldry && this._system.selectedHeraldry.largeCompositeBmpd != this.selectedFlagBitmap.bitmapData)
         {
            this.selectedFlagBitmap.bitmapData = null;
         }
         this._button$confirm.enabled = false;
         if(this._selectedLoader)
         {
            if(this._selectedLoader.heraldry)
            {
               this.selectedLoaderHandler(null);
            }
            else
            {
               this._selectedLoader.addEventListener(Event.COMPLETE,this.selectedLoaderHandler);
            }
         }
      }
      
      private function selectedLoaderHandler(param1:Event) : void
      {
         this._selectedLoader.removeEventListener(Event.COMPLETE,this.selectedLoaderHandler);
         this.showSelectedHeraldry(!!this._selectedLoader ? this._selectedLoader.heraldry : null);
         this._button$confirm.enabled = this.selectedFlagBitmap.bitmapData != null;
      }
      
      private function showSelectedHeraldry(param1:Heraldry) : void
      {
         this.selectedFlagBitmap.bitmapData = !!param1 ? param1.largeCompositeBmpd : null;
         if(this.selectedFlagBitmap.bitmapData)
         {
            this.selectedFlagBitmap.smoothing = true;
            this.selectedFlagBitmap.x = -this.selectedFlagBitmap.bitmapData.width / 2;
         }
         this._button$confirm.enabled = this.selectedFlagBitmap.bitmapData != null;
      }
      
      private function showSpinner() : void
      {
         if(this.nav)
         {
            this.nav.deactivate();
         }
         this._spinner.visible = true;
         this.spinner_rotate.rotation = 0;
         TweenMax.to(this.spinner_rotate,3,{
            "rotation":360,
            "repeat":true
         });
      }
      
      private function createNav() : void
      {
         var _loc1_:GuiSagaHeraldryTile = null;
         if(this.nav)
         {
            this.nav.cleanup();
            this.nav = null;
         }
         this.nav = new GuiGpNav(context,"heraldry",this);
         this.nav.setCallbackPress(this.navPressHandler);
         this.nav.scale = 1.5;
         this.nav.setAlignNavDefault(GuiGpAlignH.C,GuiGpAlignV.S);
         this.nav.pressOnNavigate = true;
         for each(_loc1_ in this.tiles)
         {
            _loc1_.visible = true;
            this.nav.add(_loc1_);
            this.nav.setShowControl(_loc1_,false);
         }
         this.nav.autoSelect();
         for each(_loc1_ in this.tiles)
         {
            _loc1_.visible = false;
         }
      }
      
      private function activateNav() : void
      {
         var _loc1_:GuiSagaHeraldryTile = null;
         if(Boolean(this.nav) && !this._overlayShowing)
         {
            this.nav.activate();
            this.nav.autoSelect();
            _loc1_ = this.nav.selected as GuiSagaHeraldryTile;
            if(_loc1_)
            {
               _loc1_.press();
            }
         }
      }
      
      private function hideSpinner() : void
      {
         if(!this.filterNav || !this.filterNav.isActivated)
         {
            this.activateNav();
         }
         this._spinner.visible = false;
         TweenMax.killTweensOf(this.spinner_rotate);
         this.purgeUnusedLoaders();
      }
      
      private function navPressHandler(param1:GuiSagaHeraldryTile, param2:Boolean) : Boolean
      {
         if(!param2)
         {
            this.gp_a.pulse();
            this._button$confirm.press();
            return true;
         }
         return false;
      }
      
      private function cmdfunc_b(param1:CmdExec) : void
      {
         if(this.filterNav != null && this.filterNav.isActivated && !HeraldrySystem.SUPPRESS_ADDITIONAL_HERALDRY)
         {
            this.toggleFilterNav();
         }
         else
         {
            this._button_close.press();
         }
      }
      
      private function cmdfunc_y(param1:CmdExec) : void
      {
         if(!HeraldrySystem.SUPPRESS_ADDITIONAL_HERALDRY)
         {
            this.toggleFilterNav();
            this.gp_y.pulse();
         }
      }
      
      private function cmdfunc_l1(param1:CmdExec) : void
      {
         if(this._button_prev.visible)
         {
            this._button_prev.press();
            this.gp_l1.pulse();
         }
      }
      
      private function cmdfunc_r1(param1:CmdExec) : void
      {
         if(this._button_next.visible)
         {
            this._button_next.press();
            this.gp_r1.pulse();
         }
      }
      
      private function toggleFilterNav() : void
      {
         if(this.filterNav == null)
         {
            return;
         }
         if(this.filterNav.isActivated)
         {
            GpBinder.gpbinder.removeLayer(this.filterGplayer);
            this.filterGplayer = 0;
            this.filterNav.deactivate();
            this._button_next.visible = this._button_prev.visible = true;
            this._button$confirm.visible = true;
            if(!this._spinner.visible)
            {
               this.activateNav();
            }
            this._spinner.visible = false;
         }
         else
         {
            this.filterGplayer = GpBinder.gpbinder.createLayer("GuiSagaHeraldry");
            this.gp_y.gplayer = this.filterGplayer;
            this.filterNav.activate();
            this._button_next.visible = this._button_prev.visible = false;
            this._button$confirm.visible = false;
         }
      }
      
      public function notifyOverlayChange(param1:Boolean) : void
      {
         if(this.nav)
         {
            if(param1)
            {
               this._overlayShowing = true;
               this.nav.deactivate();
            }
            else
            {
               this._overlayShowing = false;
               if(!this._spinner.visible)
               {
                  this.activateNav();
               }
            }
         }
      }
   }
}

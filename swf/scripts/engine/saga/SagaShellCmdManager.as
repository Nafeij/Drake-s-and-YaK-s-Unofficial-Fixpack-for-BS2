package engine.saga
{
   import engine.battle.board.model.IBattleBoard;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.ShellCmdManager;
   import engine.core.logging.ILogger;
   import engine.core.util.AppInfo;
   import engine.core.util.Enum;
   import engine.core.util.StringUtil;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.entity.def.Item;
   import engine.entity.def.ItemDef;
   import engine.entity.def.ItemListDef;
   import engine.landscape.travel.def.CartDef;
   import engine.saga.action.Action;
   import engine.saga.action.ActionDef;
   import engine.saga.action.ActionDefVars;
   import engine.saga.action.ActionType;
   import engine.saga.happening.HappeningDef;
   import engine.saga.save.SagaSave;
   import engine.saga.vars.IVariable;
   import engine.saga.vars.VariableBag;
   import engine.saga.vars.VariableType;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import flash.desktop.Clipboard;
   import flash.desktop.ClipboardFormats;
   
   public class SagaShellCmdManager extends ShellCmdManager
   {
       
      
      public var saga:Saga;
      
      public var acv:SagaAcvShellCmdManager;
      
      public var lb:SagaLbShellCmdManager;
      
      public var ab:SagaAbShellCmdManager;
      
      public var survival:SagaSurvivalShellCmdManager;
      
      public var happening:SagaHappeningShellCmdManager;
      
      private var pl:Function;
      
      private var pr:Function;
      
      public function SagaShellCmdManager(param1:ILogger, param2:Saga, param3:Boolean)
      {
         this.pl = StringUtil.padLeft;
         this.pr = StringUtil.padRight;
         super(param1);
         this.saga = param2;
         add("info",this.shellFuncInfo);
         this.survival = new SagaSurvivalShellCmdManager(param1,param2,param3);
         this.happening = new SagaHappeningShellCmdManager(param1,param2,param3);
         addShell("survival",this.survival);
         addShell("happening",this.happening);
         add("log",this.shellFuncLog);
         if(param3)
         {
            add("set",this.shellFuncSetVar,true);
            add("vars",this.shellFuncVars);
            add("exec",this.shellFuncExec,true);
            add("action",this.shellFuncAction,true);
            add("bookmark",this.shellFuncBookmark,true);
            add("caravan",this.shellFuncCaravan);
            add("cast",this.shellFuncCast);
            add("item_unit",this.shellFuncItemUnit,true);
            add("item_add",this.shellFuncItemAdd,true);
            add("item_all",this.shellFuncItemAll,true);
            add("item_remove",this.shellFuncItemRemove,true);
            add("market_show",this.shellFuncMarket,true);
            add("market_refresh",this.shellFuncMarketRefresh,true);
            add("save_load",this.shellFuncSaveLoad,true);
            add("save_store",this.shellFuncSaveStore,true);
            add("map_spline",this.shellFuncMapSpline,true);
            add("kills",this.shellFuncKills,true);
            add("injury",this.shellFuncInjury,true);
            add("battle_music",this.shellFuncBattleMusic,true);
            add("roster_add",this.shellFuncRosterAdd,true);
            add("speak",this.shellFuncSpeak,true);
            add("test_shatter",this.shellFuncTestShatter,true);
            add("cart",this.shellFuncCart,true);
            addAlias("carts","cart");
            this.acv = new SagaAcvShellCmdManager(param1,param2,param3);
            addShell("acv",this.acv);
            this.lb = new SagaLbShellCmdManager(param1,param2,param3);
            addShell("lb",this.lb);
            this.ab = new SagaAbShellCmdManager(param1,param2,param3);
            addShell("ab",this.ab);
         }
      }
      
      private function shellFuncInfo(param1:CmdExec) : void
      {
         logger.info("Saga: " + this.saga.def.id + " " + this.saga.def.url);
         logger.info("         paused " + this.saga.paused);
         logger.info("         halted " + this.saga.halted);
         logger.info("        halting " + this.saga.haltingCount);
         logger.info("     haltToCamp " + this.saga.haltToCamp);
         logger.info("   haltLocation " + this.saga.haltLocation);
         logger.info("         camped " + this.saga.camped);
         logger.info("        resting " + this.saga.resting);
         logger.info(" currentMusicId " + this.saga.sound.currentMusicId);
         logger.info("    showCaravan " + this.saga.showCaravan);
         logger.info("   drivingSpeed " + this.saga.travelDrivingSpeed);
         logger.info("        mapCamp " + this.saga.mapCamp);
         logger.info("  cameraPanning " + this.saga.cameraPanning);
         logger.info("     cameraLock " + this.saga.caravanCameraLock);
         logger.info("   saveSceneUrl " + this.saga.sceneUrl);
         logger.info("    sceneLoaded " + this.saga.sceneLoaded);
         logger.info("          music " + this.saga.sound.currentMusicId);
         logger.info("    battleMusic " + this.saga.battleMusicDefUrl);
         logger.info("  travelLocator " + this.saga.travelLocator);
         var _loc2_:String = this.saga.gameSceneUrl;
         var _loc3_:String = this.saga.gameConvoUrl;
         var _loc4_:IBattleBoard = this.saga.getBattleBoard();
         var _loc5_:String = !!_loc4_ ? _loc4_.def.id : null;
         logger.info("---------------");
         logger.info("       sceneUrl " + _loc2_);
         logger.info("       convoUrl " + _loc3_);
         logger.info("          board " + _loc5_);
         var _loc6_:String = "";
         if(_loc2_)
         {
            _loc6_ += "SCENE: " + _loc2_ + "\n";
         }
         if(_loc3_)
         {
            _loc6_ += "CONVO: " + _loc3_ + "\n";
         }
         if(_loc5_)
         {
            _loc6_ += "BOARD: " + _loc5_ + "\n";
         }
         Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT,_loc6_);
      }
      
      private function shellFuncVars(param1:CmdExec) : void
      {
         var _loc2_:String = null;
         var _loc7_:Caravan = null;
         var _loc8_:int = 0;
         var _loc9_:IEntityDef = null;
         var _loc10_:VariableBag = null;
         var _loc3_:Array = param1.param;
         if(_loc3_.length < 2)
         {
            logger.info("Usage:");
            logger.info("      " + _loc3_[0] + " global         [filter]");
            logger.info("      " + _loc3_[0] + " caravan        [filter]");
            logger.info("      " + _loc3_[0] + " caravan.<name> [filter]");
            logger.info("      " + _loc3_[0] + " cast           [filter]");
            logger.info("      " + _loc3_[0] + " cast.<unit>    [filter]");
            logger.info("      " + _loc3_[0] + " scene          [filter]");
            logger.info("      " + _loc3_[0] + " cnv            [filter]");
            logger.info("      " + _loc3_[0] + " cnvn           [filter]");
            return;
         }
         _loc2_ = String(_loc3_[1]);
         var _loc4_:String = "";
         if(_loc3_.length > 2)
         {
            _loc4_ = String(_loc3_[2]);
         }
         if(StringUtil.startsWith(_loc2_,"g"))
         {
            this.saga.global.debugPrintLog(logger,_loc4_);
            return;
         }
         if(_loc2_ == "scene")
         {
            this.saga._vars._scene.debugPrintLog(logger,_loc4_);
            return;
         }
         if(_loc2_ == "cnvn")
         {
            this.saga._vars._cnvn.debugPrintLog(logger,_loc4_);
            return;
         }
         if(_loc2_ == "cnv")
         {
            this.saga._vars._cnv.debugPrintLog(logger,_loc4_);
            return;
         }
         var _loc5_:int = 0;
         var _loc6_:String = null;
         _loc5_ = _loc2_.indexOf(".");
         if(_loc5_ > 0)
         {
            _loc6_ = _loc2_.substr(_loc5_ + 1);
         }
         if(StringUtil.startsWith(_loc2_,"car"))
         {
            for each(_loc7_ in this.saga.caravans)
            {
               if(_loc6_)
               {
                  if(_loc6_ != "*" && _loc7_.def.name != _loc6_)
                  {
                     continue;
                  }
               }
               else if(_loc7_ != this.saga.caravan)
               {
                  continue;
               }
               _loc7_.vars.debugPrintLog(logger,_loc4_);
            }
            return;
         }
         if(StringUtil.startsWith(_loc2_,"cas"))
         {
            _loc8_ = 0;
            for(; _loc8_ < this.saga.def.cast.numEntityDefs; _loc8_++)
            {
               _loc9_ = this.saga.def.cast.getEntityDef(_loc8_);
               if(_loc6_)
               {
                  if(_loc6_ != "*" && _loc9_.id != _loc6_)
                  {
                     continue;
                  }
               }
               _loc10_ = _loc9_.vars as VariableBag;
               _loc10_.debugPrintLog(logger,_loc4_);
            }
            return;
         }
         logger.error("No such var category [" + _loc2_ + "]");
      }
      
      private function shellFuncLog(param1:CmdExec) : void
      {
         if(!SagaLog.ENABLED)
         {
            logger.info("Saga log not enabled");
            return;
         }
         var _loc2_:String = this.saga.slog.reportSagaLog();
         logger.info("\n" + _loc2_);
      }
      
      private function shellFuncCart(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(!_loc2_ || _loc2_.length < 2)
         {
            this.saga.def.cartDefs.logCarts(logger);
            return;
         }
         var _loc3_:String = _loc2_[1] as String;
         var _loc4_:CartDef = this.saga.def.cartDefs.getCartDefById(_loc3_);
         if(!_loc4_)
         {
            logger.error("Invalid Cart Id: " + _loc3_);
            return;
         }
         if(!_loc4_.isValid(this.saga))
         {
            logger.error("Cart is not valid for current saga: \n" + _loc4_.getDebugString());
            return;
         }
         logger.info("Setting Saga Cart: \n" + _loc4_.getDebugString());
         this.saga.cartId = _loc4_.id;
      }
      
      private function shellFuncSetVar(param1:CmdExec) : void
      {
         var _loc6_:String = null;
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.error("Usage: set <varname> <value>");
            return;
         }
         var _loc3_:String = String(_loc2_[1]);
         var _loc4_:IVariable = this.saga.getVar(_loc3_,null);
         if(!_loc4_)
         {
            logger.error("No such variable: " + _loc3_);
            return;
         }
         if(_loc2_.length < 3)
         {
            _loc6_ = _loc4_.asString;
            _loc6_ = !!_loc6_ ? _loc6_ : "";
            if(_loc4_.def.type == VariableType.INTEGER)
            {
               if(_loc6_.indexOf("0x") != 0)
               {
                  _loc6_ += " (0x" + _loc4_.asUnsigned.toString(16) + ")";
               }
            }
            logger.info("Usage: set " + _loc3_ + " <value>");
            logger.info("Current value " + _loc6_);
            return;
         }
         var _loc5_:String = String(_loc2_[2]);
         this.saga.setVar(_loc3_,_loc5_);
      }
      
      private function shellFuncExec(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length != 2)
         {
            logger.error("Usage: exec <happening id>");
            return;
         }
         var _loc3_:String = String(_loc2_[1]);
         this.saga.endAllHappenings();
         this.saga.executeHappeningById(_loc3_,null,param1.cmdline);
      }
      
      private function shellFuncAction(param1:CmdExec) : void
      {
         var pfx:String = null;
         var pfxi:int = 0;
         var jj:String = null;
         var jo:Object = null;
         var ad:ActionDefVars = null;
         var a:Action = null;
         var c:CmdExec = param1;
         try
         {
            pfx = "json=";
            pfxi = c.cmdline.indexOf(pfx);
            if(pfxi < 0)
            {
               logger.error("Usage: action json=<json>");
               return;
            }
            jj = c.cmdline.substr(pfxi + pfx.length);
            jo = JSON.parse(jj);
            ad = new ActionDefVars(null).fromJson(jo,logger);
            a = this.saga.executeActionDef(ad,null,null);
         }
         catch(e:Error)
         {
            logger.error(e.getStackTrace());
         }
      }
      
      private function shellFuncItemUnit(param1:CmdExec) : void
      {
         var _loc7_:Item = null;
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.error("Usage: item_unit <unit> [item]");
            return;
         }
         var _loc3_:String = String(_loc2_[1]);
         var _loc4_:String = _loc2_.length >= 3 ? String(_loc2_[2]) : null;
         var _loc5_:Caravan = this.saga.caravan;
         var _loc6_:IEntityDef = _loc5_._legend.roster.getEntityDefById(_loc3_);
         if(!_loc6_)
         {
            logger.error("No such entity [" + _loc3_ + "]");
            return;
         }
         if(_loc4_)
         {
            _loc7_ = _loc5_._legend._items.removeItemById(_loc4_);
            if(!_loc7_)
            {
               logger.error("No such item [" + _loc4_ + "]");
            }
            _loc6_.defItem = _loc7_;
            _loc7_.owner = _loc6_;
         }
         else if(_loc6_.defItem)
         {
            _loc6_.defItem.owner = null;
            _loc5_._legend._items.addItem(_loc6_.defItem);
            _loc6_.defItem = null;
         }
      }
      
      private function shellFuncKills(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.error("Usage: kills <unit> <killcount>");
            return;
         }
         var _loc3_:String = String(_loc2_[1]);
         var _loc4_:int = int(_loc2_[2]);
         var _loc5_:Caravan = this.saga.caravan;
         var _loc6_:IEntityDef = _loc5_._legend.roster.getEntityDefById(_loc3_);
         if(!_loc6_)
         {
            logger.error("No such entity [" + _loc3_ + "]");
            return;
         }
         _loc6_.stats.setBase(StatType.KILLS,_loc4_);
      }
      
      private function shellFuncInjury(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.error("Usage: injury <unit> <days>");
            return;
         }
         var _loc3_:String = String(_loc2_[1]);
         var _loc4_:int = int(_loc2_[2]);
         var _loc5_:Caravan = this.saga.caravan;
         var _loc6_:IEntityDef = _loc5_._legend.roster.getEntityDefById(_loc3_);
         if(!_loc6_)
         {
            logger.error("No such entity [" + _loc3_ + "]");
            return;
         }
         _loc6_.stats.setBase(StatType.INJURY,_loc4_);
         _loc5_._legend.roster.sortEntities();
      }
      
      private function shellFuncItemAll(param1:CmdExec) : void
      {
         var _loc3_:ItemDef = null;
         var _loc2_:ItemListDef = this.saga.def.itemDefs;
         for each(_loc3_ in _loc2_.items)
         {
            this.saga.gainItemDef(_loc3_);
         }
      }
      
      private function shellFuncItemAdd(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 1)
         {
            logger.error("Usage: item_add <itemdef>");
            return;
         }
         var _loc3_:String = String(_loc2_[1]);
         var _loc4_:Caravan = this.saga.caravan;
         var _loc5_:ItemDef = this.saga.def.itemDefs.getItemDef(_loc3_);
         if(!_loc5_)
         {
            logger.error("No such itemdef [" + _loc3_ + "]");
            return;
         }
         var _loc6_:Item = this.saga.gainItemDef(_loc5_);
         if(!_loc6_)
         {
            logger.error("Unable to create item [" + _loc3_ + "]");
            return;
         }
         logger.info("Created item [" + _loc6_.id + "]");
      }
      
      private function shellFuncItemRemove(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 1)
         {
            logger.error("Usage: item_remove <itemid>");
            return;
         }
         var _loc3_:String = String(_loc2_[1]);
         var _loc4_:Caravan = this.saga.caravan;
         var _loc5_:Item = _loc4_._legend._items.removeItemById(_loc3_);
         if(!_loc5_)
         {
            logger.error("Unable to remove item");
            return;
         }
      }
      
      private function shellFuncCaravan(param1:CmdExec) : void
      {
         var i:int;
         var j:int;
         var item:Item = null;
         var red:IEntityDef = null;
         var rt:int = 0;
         var rk:int = 0;
         var rks:String = null;
         var rrp:int = 0;
         var rts:String = null;
         var rrps:String = null;
         var ij:int = 0;
         var ijs:String = null;
         var itms:String = null;
         var pev:IEntityDef = null;
         var c:CmdExec = param1;
         var cv:Caravan = this.saga.caravan;
         if(!cv)
         {
            logger.info("No caravan");
            return;
         }
         logger.info(" CARAVAN: " + cv.def.name + " LEADER: [" + cv.leader + "]");
         logger.info("  roster:");
         logger.info("      " + this.pr("id"," ",20) + this.pl(" rank"," ",5) + this.pl(" talk"," ",8) + this.pl(" req"," ",8) + this.pl(" injury"," ",8) + this.pl(" item"," ",16));
         logger.info("      " + this.pr("","-",20) + this.pr(" ","-",5) + this.pr(" ","-",8) + this.pr(" ","-",8) + this.pr(" ","-",16));
         i = 0;
         while(i < cv._legend.roster.numEntityDefs)
         {
            red = cv._legend.roster.getEntityDef(i);
            try
            {
               rt = this.saga.getVar(red.id + "." + SagaVar.VAR_UNIT_TALK,null).asInteger;
               rk = red.stats.rank - 1;
               rks = this.pl(rk.toString()," ",5);
               rrp = this.saga.getVar(red.id + "." + SagaVar.VAR_UNIT_PARTY_REQUIRED,null).asInteger;
               rts = this.pl(!!rt ? rt.toString() : ""," ",8);
               rrps = this.pl(!!rrp ? rrp.toString() : ""," ",8);
               ij = int(red.stats.getValue(StatType.INJURY));
               ijs = this.pl(!!ij ? " injury=" + ij.toString() : ""," ",8);
               itms = " " + this.pr(!!red.defItem ? red.defItem.id : ""," ",16);
            }
            catch(e:Error)
            {
               logger.error("Problem with roster member [" + red + "]:\n" + e.getStackTrace());
            }
            logger.info("      " + this.pr(red.id," ",20) + rks + rts + rrps + ijs + itms);
            i++;
         }
         logger.info("  party:");
         j = 0;
         while(j < cv._legend.party.numMembers)
         {
            pev = cv._legend.party.getMember(j);
            if(!pev)
            {
               logger.error("      NULL PARTY MEMBER " + j);
            }
            else
            {
               logger.info("      " + pev.id);
            }
            j++;
         }
         logger.info("  items:");
         for each(item in cv._legend._items.items)
         {
            logger.info("      " + item.id);
         }
      }
      
      private function shellFuncCast(param1:CmdExec) : void
      {
         var _loc2_:String = null;
         var _loc6_:Enum = null;
         var _loc8_:StatType = null;
         var _loc9_:IEntityListDef = null;
         var _loc10_:int = 0;
         var _loc11_:IEntityDef = null;
         var _loc12_:* = null;
         var _loc13_:Stat = null;
         var _loc3_:Array = param1.param;
         if(_loc3_.length > 1)
         {
            _loc2_ = String(_loc3_[1]);
         }
         logger.info(" CAST:");
         var _loc4_:Vector.<Enum> = Enum.getVector(StatType);
         var _loc5_:int = 16;
         var _loc7_:String = this.pl(""," ",_loc5_);
         for each(_loc6_ in _loc4_)
         {
            _loc8_ = _loc6_ as StatType;
            if(_loc8_.volatile)
            {
               _loc7_ += this.pl(_loc8_.abbrev," ",4);
            }
         }
         logger.info(_loc7_);
         _loc9_ = this.saga.def.cast;
         _loc10_ = 0;
         while(_loc10_ < _loc9_.numEntityDefs)
         {
            _loc11_ = _loc9_.getEntityDef(_loc10_);
            if(!(Boolean(_loc2_) && _loc11_.id.indexOf(_loc2_) < 0))
            {
               _loc12_ = this.pr(StringUtil.truncate(_loc11_.id,_loc5_ - 1)," ",_loc5_);
               for each(_loc6_ in _loc4_)
               {
                  _loc8_ = _loc6_ as StatType;
                  if(_loc8_.volatile)
                  {
                     _loc13_ = _loc11_.stats.getStat(_loc8_,false);
                     if(_loc13_)
                     {
                        _loc12_ += this.pl(_loc13_.base.toString()," ",4);
                     }
                     else
                     {
                        _loc12_ += "    ";
                     }
                  }
               }
               logger.info(_loc12_);
            }
            _loc10_++;
         }
      }
      
      private function shellFuncBookmark(param1:CmdExec) : void
      {
         var _loc2_:HappeningDef = null;
         var _loc6_:String = null;
         var _loc3_:Array = param1.param;
         var _loc4_:Array = [];
         if(_loc3_.length == 1)
         {
            for each(_loc2_ in this.saga.def.happenings.list)
            {
               if(StringUtil.startsWith(_loc2_.id,"bk_"))
               {
                  _loc4_.push(_loc2_.id);
               }
            }
            _loc4_.sort();
            for each(_loc6_ in _loc4_)
            {
               logger.info("    " + _loc6_);
            }
            return;
         }
         var _loc5_:String = String(_loc3_[1]);
         this.saga.gotoBookmark(_loc5_,true);
      }
      
      private function shellFuncMarket(param1:CmdExec) : void
      {
         this.saga.showSagaMarket();
      }
      
      private function shellFuncMarketRefresh(param1:CmdExec) : void
      {
         this.saga.market.refresh();
      }
      
      private function shellFuncSaveLoad(param1:CmdExec) : void
      {
         var _loc5_:int = 0;
         var _loc6_:Array = null;
         var _loc7_:SagaSave = null;
         var _loc8_:Object = null;
         var _loc9_:SagaSave = null;
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            _loc5_ = -1;
            while(_loc5_ < Saga.PROFILE_COUNT)
            {
               logger.info("PROFILE " + _loc5_);
               _loc6_ = this.saga.saveManager.getSavesInProfile(this.saga.def.id,_loc5_);
               if(!_loc6_ || _loc6_.length == 0)
               {
                  logger.info("  No save games.");
               }
               else
               {
                  for each(_loc7_ in _loc6_)
                  {
                     logger.info("    " + _loc7_.id);
                  }
               }
               _loc5_++;
            }
            return;
         }
         var _loc3_:String = String(_loc2_[1]);
         var _loc4_:int = this.saga.profile_index;
         if(_loc2_.length > 2)
         {
            _loc4_ = int(_loc2_[2]);
         }
         if(StringUtil.startsWith(_loc3_,"file://"))
         {
            _loc8_ = this.saga.appinfo.loadFileJson(AppInfo.DIR_ABSOLUTE,_loc3_);
            _loc9_ = new SagaSave("file").fromJson(_loc8_,logger);
            this.saga.loadExistingSave(_loc9_,5);
            return;
         }
         this.saga.loadSaga(this.saga.def.id,_loc3_,_loc4_);
      }
      
      private function shellFuncSaveStore(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.info("Usage: save_store <id>");
            return;
         }
         var _loc3_:String = String(_loc2_[1]);
         this.saga.saveSaga(_loc3_,null,null);
      }
      
      private function shellFuncMapSpline(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 3)
         {
            logger.info("Usage: map_spline <id> <key> <t>");
            logger.info("       Use a dot \'.\' for null key");
            if(this.saga.caravan)
            {
               logger.info("current: " + this.saga.caravan.map_spline_id + "/" + this.saga.caravan.map_spline_key + "/" + this.saga.caravan.map_spline_t);
            }
            return;
         }
         var _loc3_:String = String(_loc2_[1]);
         var _loc4_:String = _loc2_[2] != "." ? String(_loc2_[2]) : null;
         var _loc5_:Number = Number(_loc2_[3]);
         this.saga.caravan.setMapSpline(_loc3_,_loc4_,_loc5_);
      }
      
      private function shellFuncBattleMusic(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.info("Usage: " + _loc2_[0] + " <id>");
            return;
         }
         var _loc3_:String = String(_loc2_[1]);
         this.saga.battleMusicDefUrl = _loc3_;
      }
      
      private function shellFuncRosterAdd(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 2)
         {
            logger.info("Usage: " + _loc2_[0] + " <id>");
            return;
         }
         var _loc3_:String = String(_loc2_[1]);
         var _loc4_:ActionDef = new ActionDef(null);
         _loc4_.type = ActionType.ROSTER_ADD;
         _loc4_.also_party = this.saga.caravan._legend.party.numMembers < 6;
         _loc4_.id = _loc3_;
         this.saga.executeActionDef(_loc4_,null,null);
      }
      
      private function shellFuncSpeak(param1:CmdExec) : void
      {
         var _loc2_:Array = param1.param;
         if(_loc2_.length < 4)
         {
            logger.info("Usage: " + _loc2_[0] + " <speaker> <time> <anchor> <msg>");
            return;
         }
         var _loc3_:String = String(_loc2_[1]);
         if(_loc3_ == ".")
         {
            _loc3_ = null;
         }
         var _loc4_:Number = Number(_loc2_[2]);
         var _loc5_:String = String(_loc2_[3]);
         _loc2_.splice(0,3);
         var _loc6_:String = _loc2_.join(" ");
         var _loc7_:ActionDef = new ActionDef(null);
         _loc7_.type = ActionType.SPEAK;
         _loc7_.speaker = _loc3_;
         _loc7_.time = _loc4_;
         _loc7_.anchor = _loc5_;
         _loc7_.msg = _loc6_;
         this.saga.executeActionDef(_loc7_,null,null);
      }
      
      private function shellFuncTestShatter(param1:CmdExec) : void
      {
         var _loc2_:ActionDef = new ActionDef(null);
         _loc2_.type = ActionType.DISPLAY_SHATTER_GUI;
         _loc2_.param = "tally_additional,doomsday_timer_add, ;tally_peasants,num_peasants,tally_peasant_mult;start_peasants_fall,end_peasants_fall;tally_fighters,num_fighters,tally_figher_mult;start_fighters_fall,end_fighters_fall;tally_varl,num_varl,tally_varl_mult;start_varl_fall, end_varl_fall; tally_supplies,supplies,tally_supplies_mult;start_supplies_fall,end_supplies_fall;start_button_fall,end_button_fall;start_hub_shatter,end_hub_shatter";
         this.saga.executeActionDef(_loc2_,null,null);
      }
   }
}

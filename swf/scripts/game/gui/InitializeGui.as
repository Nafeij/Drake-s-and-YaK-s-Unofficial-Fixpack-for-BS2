package game.gui
{
   import assets.ability_popup;
   import assets.alert_banner_left_red;
   import assets.alert_banner_left_tourney;
   import assets.alert_banner_right_green;
   import assets.alert_banner_right_red;
   import assets.alert_banner_right_tourney;
   import assets.battle_help_saga;
   import assets.battle_hud;
   import assets.battle_info_flag;
   import assets.battle_info_flag_absorption;
   import assets.battle_info_flag_prop;
   import assets.battle_initiative;
   import assets.battle_objective;
   import assets.battle_options_button;
   import assets.battle_redeploy_loading_popup;
   import assets.battle_tooltip;
   import assets.brd_order_frame;
   import assets.brd_redeployment;
   import assets.btl_forgeahead_normal_gethit;
   import assets.btl_forgeahead_pillage_gethit;
   import assets.btl_go_battle_text;
   import assets.btl_go_war_text;
   import assets.btl_insult;
   import assets.btl_pillage2_text;
   import assets.btl_pillage_text;
   import assets.btl_roster_title;
   import assets.btl_wave_enemy_reinforcements;
   import assets.btl_wave_reinforcements;
   import assets.btl_wave_respite;
   import assets.cart_picker;
   import assets.close_button_nw;
   import assets.cnv_convo;
   import assets.cnv_poppening;
   import assets.cnv_war;
   import assets.corner_btn_banner;
   import assets.corner_btn_help;
   import assets.credits;
   import assets.credits_section1;
   import assets.credits_section2;
   import assets.credits_section3;
   import assets.credits_section_bmp;
   import assets.darkness_transition;
   import assets.devpanel;
   import assets.dialog_download;
   import assets.difficulty;
   import assets.enemy_popup2;
   import assets.gp_config;
   import assets.gp_pointer;
   import assets.gpc_state;
   import assets.gui_caption;
   import assets.gui_damage_flag;
   import assets.gui_dialog;
   import assets.gui_horn;
   import assets.gui_map_camp;
   import assets.gui_news_toggle;
   import assets.gui_speak_left;
   import assets.gui_speak_right;
   import assets.gui_talkie_left;
   import assets.gui_talkie_right;
   import assets.gui_textfield;
   import assets.gui_travel_dark_top;
   import assets.gui_travel_dark_top_shattered;
   import assets.gui_travel_top;
   import assets.gui_travel_top_shattered;
   import assets.gui_travel_top_toggle;
   import assets.gui_valka_spear;
   import assets.lang;
   import assets.loading;
   import assets.loading_saga;
   import assets.map_info;
   import assets.match_resolution;
   import assets.move_popup;
   import assets.network_problem;
   import assets.nx_a;
   import assets.nx_b;
   import assets.nx_button_cluster;
   import assets.nx_dpad_d;
   import assets.nx_dpad_l;
   import assets.nx_dpad_ld;
   import assets.nx_dpad_lr;
   import assets.nx_dpad_lrd;
   import assets.nx_dpad_lru;
   import assets.nx_dpad_lrud;
   import assets.nx_dpad_lu;
   import assets.nx_dpad_lud;
   import assets.nx_dpad_r;
   import assets.nx_dpad_rd;
   import assets.nx_dpad_ru;
   import assets.nx_dpad_rud;
   import assets.nx_dpad_u;
   import assets.nx_dpad_ud;
   import assets.nx_l;
   import assets.nx_lstick;
   import assets.nx_lstick_click;
   import assets.nx_lstick_d;
   import assets.nx_lstick_l;
   import assets.nx_lstick_r;
   import assets.nx_lstick_u;
   import assets.nx_minus;
   import assets.nx_plus;
   import assets.nx_r;
   import assets.nx_rstick;
   import assets.nx_rstick_click;
   import assets.nx_rstick_d;
   import assets.nx_rstick_l;
   import assets.nx_rstick_r;
   import assets.nx_rstick_u;
   import assets.nx_x;
   import assets.nx_y;
   import assets.nx_zl;
   import assets.nx_zr;
   import assets.opt_audio;
   import assets.opt_battle_objectives;
   import assets.pg_abl_pop2;
   import assets.prop_popup;
   import assets.proving_grounds;
   import assets.ps3_button_cluster;
   import assets.ps3_circle;
   import assets.ps3_cross;
   import assets.ps3_dpad_d;
   import assets.ps3_dpad_l;
   import assets.ps3_dpad_ld;
   import assets.ps3_dpad_lr;
   import assets.ps3_dpad_lrd;
   import assets.ps3_dpad_lru;
   import assets.ps3_dpad_lrud;
   import assets.ps3_dpad_lu;
   import assets.ps3_dpad_lud;
   import assets.ps3_dpad_r;
   import assets.ps3_dpad_rd;
   import assets.ps3_dpad_ru;
   import assets.ps3_dpad_rud;
   import assets.ps3_dpad_u;
   import assets.ps3_dpad_ud;
   import assets.ps3_l1;
   import assets.ps3_l2;
   import assets.ps3_l3;
   import assets.ps3_lstick;
   import assets.ps3_lstick_d;
   import assets.ps3_lstick_l;
   import assets.ps3_lstick_r;
   import assets.ps3_lstick_u;
   import assets.ps3_r1;
   import assets.ps3_r2;
   import assets.ps3_r3;
   import assets.ps3_rstick;
   import assets.ps3_rstick_d;
   import assets.ps3_rstick_l;
   import assets.ps3_rstick_r;
   import assets.ps3_rstick_u;
   import assets.ps3_select;
   import assets.ps3_square;
   import assets.ps3_start;
   import assets.ps3_triangle;
   import assets.ps4_button_cluster;
   import assets.ps4_dpad_d;
   import assets.ps4_dpad_l;
   import assets.ps4_dpad_ld;
   import assets.ps4_dpad_lr;
   import assets.ps4_dpad_lrd;
   import assets.ps4_dpad_lru;
   import assets.ps4_dpad_lrud;
   import assets.ps4_dpad_lu;
   import assets.ps4_dpad_lud;
   import assets.ps4_dpad_r;
   import assets.ps4_dpad_rd;
   import assets.ps4_dpad_ru;
   import assets.ps4_dpad_rud;
   import assets.ps4_dpad_u;
   import assets.ps4_dpad_ud;
   import assets.ps4_options;
   import assets.ps4_share;
   import assets.psv_select;
   import assets.psv_start;
   import assets.saga2_newgame;
   import assets.saga2_survival_start;
   import assets.saga2_survival_win;
   import assets.saga3_newgame;
   import assets.saga_heraldry;
   import assets.saga_market;
   import assets.saga_options;
   import assets.saga_options_gp;
   import assets.saga_pairing_prompt;
   import assets.saga_selector_12;
   import assets.saga_start;
   import assets.save_profile;
   import assets.save_saveload;
   import assets.self_popup;
   import assets.start_news;
   import assets.stat_tooltip;
   import assets.survival_battle_popup;
   import assets.survival_dlc_popup;
   import assets.tally_number;
   import assets.tally_text;
   import assets.tut_arrow;
   import assets.tut_block;
   import assets.tut_check_button;
   import assets.tut_eyeball;
   import assets.vfx_earn_renown;
   import assets.vfx_item;
   import assets.vfx_survival_died;
   import assets.x360_a;
   import assets.x360_b;
   import assets.x360_back;
   import assets.x360_button_cluster;
   import assets.x360_dpad_d;
   import assets.x360_dpad_l;
   import assets.x360_dpad_ld;
   import assets.x360_dpad_lr;
   import assets.x360_dpad_lrd;
   import assets.x360_dpad_lru;
   import assets.x360_dpad_lrud;
   import assets.x360_dpad_lu;
   import assets.x360_dpad_lud;
   import assets.x360_dpad_r;
   import assets.x360_dpad_rd;
   import assets.x360_dpad_ru;
   import assets.x360_dpad_rud;
   import assets.x360_dpad_u;
   import assets.x360_dpad_ud;
   import assets.x360_l3;
   import assets.x360_lb;
   import assets.x360_lstick;
   import assets.x360_lstick_d;
   import assets.x360_lstick_l;
   import assets.x360_lstick_r;
   import assets.x360_lstick_u;
   import assets.x360_lt;
   import assets.x360_r3;
   import assets.x360_rb;
   import assets.x360_rstick;
   import assets.x360_rstick_d;
   import assets.x360_rstick_l;
   import assets.x360_rstick_r;
   import assets.x360_rstick_u;
   import assets.x360_rt;
   import assets.x360_start;
   import assets.x360_x;
   import assets.x360_y;
   import assets.xbo_back;
   import assets.xbo_button_cluster;
   import assets.xbo_dpad_d;
   import assets.xbo_dpad_l;
   import assets.xbo_dpad_ld;
   import assets.xbo_dpad_lr;
   import assets.xbo_dpad_lrd;
   import assets.xbo_dpad_lru;
   import assets.xbo_dpad_lrud;
   import assets.xbo_dpad_lu;
   import assets.xbo_dpad_lud;
   import assets.xbo_dpad_r;
   import assets.xbo_dpad_rd;
   import assets.xbo_dpad_ru;
   import assets.xbo_dpad_rud;
   import assets.xbo_dpad_u;
   import assets.xbo_dpad_ud;
   import assets.xbo_start;
   import engine.core.gp.GpControlButton;
   import engine.core.locale.LocaleFont;
   import engine.core.logging.ILogger;
   import engine.gui.GameTextBitmapGenerator;
   import engine.gui.GuiCaption;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpControlButtons;
   import engine.gui.GuiUtil;
   import flash.display.MovieClip;
   import flash.events.Event;
   import game.cfg.GameAssetsDef;
   import game.gui.page.AssembleHeroesPage;
   import game.gui.page.BattleHudPageAbilityPopup;
   import game.gui.page.BattleHudPageLoadHelper;
   import game.gui.page.BattleHudPageLoadingOverlayHelper;
   import game.gui.page.BattleHudPagePopupLoadHelper;
   import game.gui.page.BattleHudPageRedeployHelper;
   import game.gui.page.ConvoPage;
   import game.gui.page.CreditsPage;
   import game.gui.page.GameLoadingPage;
   import game.gui.page.HeroesPage;
   import game.gui.page.MapCampPage;
   import game.gui.page.MatchResolutionPage;
   import game.gui.page.PoppeningPage;
   import game.gui.page.ProvingGroundsPage;
   import game.gui.page.SagaNewGamePage;
   import game.gui.page.SagaOptionsPage;
   import game.gui.page.SagaPairingPrompt;
   import game.gui.page.SagaSelectorPage;
   import game.gui.page.SagaStartPage;
   import game.gui.page.SagaSurvivalBattlePopupPage;
   import game.gui.page.SagaSurvivalStartPage;
   import game.gui.page.SagaSurvivalWinPage;
   import game.gui.page.SaveLoadPage;
   import game.gui.page.SaveProfilePage;
   import game.gui.page.ScenePage;
   import game.gui.page.ScenePageBattleDamageFlags;
   import game.gui.page.ScenePageBattleInfoFlags;
   import game.gui.page.ScenePageBattleVfx;
   import game.gui.page.ScenePageSpeechBubbles;
   import game.gui.page.TallyPage;
   import game.gui.page.TravelPage;
   import game.gui.page.TravelPageTalkies;
   import game.gui.page.WarPage;
   import game.gui.page.WarResolutionPage;
   import game.gui.page.battle.GuiBattleObjectives;
   import game.gui.pages.GuiGpConfig;
   import game.view.GameDevPanel;
   import game.view.GamePageManagerAdapterCartPicker;
   import game.view.GamePageManagerAdapterSagaHeraldry;
   import game.view.GamePageManagerAdapterSagaMarket;
   import game.view.NetworkProblemDisplay;
   import game.view.TutorialLayer;
   
   public class InitializeGui
   {
       
      
      public function InitializeGui()
      {
         super();
      }
      
      private static function checkGuiClass(param1:Boolean, param2:Class, param3:ILogger) : Class
      {
         var o:Object = null;
         var mc:MovieClip = null;
         var checkCtors:Boolean = param1;
         var clazz:Class = param2;
         var logger:ILogger = param3;
         if(checkCtors)
         {
            try
            {
               o = new clazz();
               mc = o as MovieClip;
               if(!mc)
               {
                  logger.error("InitializeGui clazz [" + clazz + "] is not a MovieClip");
               }
               else
               {
                  GuiUtil.attemptStopAllMovieClips(mc);
                  if(mc && mc.loaderInfo && Boolean(mc.loaderInfo.loader))
                  {
                     mc.loaderInfo.loader.unloadAndStop();
                  }
               }
            }
            catch(e:Error)
            {
               logger.error("InitializeGui clazz [" + clazz + "] will not construct");
               logger.error(e.getStackTrace());
            }
         }
         return clazz;
      }
      
      private static function fcHandler(param1:Event) : void
      {
         if(param1.target.name == "match_resolution")
         {
         }
      }
      
      private static function setupSwitchControls(param1:String, param2:String) : void
      {
         var _loc3_:GuiGpControlButtons = GuiGp.getControlButtonsForVisualCategory(param1);
         var _loc4_:GuiGpControlButtons = GuiGp.getControlButtonsForVisualCategory(param2);
         _loc3_.addButton(GpControlButton.A,nx_a);
         _loc3_.addButton(GpControlButton.B,nx_b);
         _loc3_.addButton(GpControlButton.Y,nx_y);
         _loc3_.addButton(GpControlButton.X,nx_x);
         _loc3_.addButton(GpControlButton.D_D,nx_dpad_d);
         _loc3_.addButton(GpControlButton.D_L,nx_dpad_l);
         _loc3_.addButton(GpControlButton.D_LD,nx_dpad_ld);
         _loc3_.addButton(GpControlButton.D_LR,nx_dpad_lr);
         _loc3_.addButton(GpControlButton.D_LRD,nx_dpad_lrd);
         _loc3_.addButton(GpControlButton.D_LRU,nx_dpad_lru);
         _loc3_.addButton(GpControlButton.D_LRUD,nx_dpad_lrud);
         _loc3_.addButton(GpControlButton.D_LU,nx_dpad_lu);
         _loc3_.addButton(GpControlButton.D_LUD,nx_dpad_lud);
         _loc3_.addButton(GpControlButton.D_R,nx_dpad_r);
         _loc3_.addButton(GpControlButton.D_RD,nx_dpad_rd);
         _loc3_.addButton(GpControlButton.D_RU,nx_dpad_ru);
         _loc3_.addButton(GpControlButton.D_RUD,nx_dpad_rud);
         _loc3_.addButton(GpControlButton.D_U,nx_dpad_u);
         _loc3_.addButton(GpControlButton.D_UD,nx_dpad_ud);
         _loc3_.addButton(GpControlButton.L1,nx_l);
         _loc3_.addButton(GpControlButton.R1,nx_r);
         _loc3_.addButton(GpControlButton.L2,nx_zl);
         _loc3_.addButton(GpControlButton.R2,nx_zr);
         _loc3_.addButton(GpControlButton.L3,nx_lstick_click);
         _loc3_.addButton(GpControlButton.R3,nx_rstick_click);
         _loc3_.addButton(GpControlButton.LSTICK,nx_lstick);
         _loc3_.addButton(GpControlButton.RSTICK,nx_rstick);
         _loc3_.addButton(GpControlButton.LSTICK_LEFT,nx_lstick_l);
         _loc3_.addButton(GpControlButton.LSTICK_RIGHT,nx_lstick_r);
         _loc3_.addButton(GpControlButton.LSTICK_UP,nx_lstick_u);
         _loc3_.addButton(GpControlButton.LSTICK_DOWN,nx_lstick_d);
         _loc3_.addButton(GpControlButton.RSTICK_LEFT,nx_rstick_l);
         _loc3_.addButton(GpControlButton.RSTICK_RIGHT,nx_rstick_r);
         _loc3_.addButton(GpControlButton.RSTICK_UP,nx_rstick_u);
         _loc3_.addButton(GpControlButton.RSTICK_DOWN,nx_rstick_d);
         _loc3_.addButton(GpControlButton.START,nx_plus);
         _loc3_.addButton(GpControlButton.MENU,nx_minus);
         _loc3_.addButton(GpControlButton.BUTTON_CLUSTER,nx_button_cluster);
         _loc3_.addButton(GpControlButton.DPAD,nx_dpad_lrud);
         _loc3_.addButton(GpControlButton.POINTER,gp_pointer);
      }
      
      private static function setupPs4Controls(param1:String, param2:String) : void
      {
         var _loc3_:GuiGpControlButtons = GuiGp.getControlButtonsForVisualCategory(param1);
         var _loc4_:GuiGpControlButtons = GuiGp.getControlButtonsForVisualCategory(param2);
         _loc3_.fallback = _loc4_;
         _loc3_.addButton(GpControlButton.D_D,ps4_dpad_d);
         _loc3_.addButton(GpControlButton.D_L,ps4_dpad_l);
         _loc3_.addButton(GpControlButton.D_LD,ps4_dpad_ld);
         _loc3_.addButton(GpControlButton.D_LR,ps4_dpad_lr);
         _loc3_.addButton(GpControlButton.D_LRD,ps4_dpad_lrd);
         _loc3_.addButton(GpControlButton.D_LRU,ps4_dpad_lru);
         _loc3_.addButton(GpControlButton.D_LRUD,ps4_dpad_lrud);
         _loc3_.addButton(GpControlButton.D_LU,ps4_dpad_lu);
         _loc3_.addButton(GpControlButton.D_LUD,ps4_dpad_lud);
         _loc3_.addButton(GpControlButton.D_R,ps4_dpad_r);
         _loc3_.addButton(GpControlButton.D_RD,ps4_dpad_rd);
         _loc3_.addButton(GpControlButton.D_RU,ps4_dpad_ru);
         _loc3_.addButton(GpControlButton.D_RUD,ps4_dpad_rud);
         _loc3_.addButton(GpControlButton.D_U,ps4_dpad_u);
         _loc3_.addButton(GpControlButton.D_UD,ps4_dpad_ud);
         _loc3_.addButton(GpControlButton.START,ps4_options);
         _loc3_.addButton(GpControlButton.MENU,ps4_share);
         _loc3_.addButton(GpControlButton.BUTTON_CLUSTER,ps4_button_cluster);
         _loc3_.addButton(GpControlButton.DPAD,ps4_dpad_lrud);
      }
      
      private static function setupPsvControls(param1:String, param2:String) : void
      {
         var _loc3_:GuiGpControlButtons = GuiGp.getControlButtonsForVisualCategory(param1);
         var _loc4_:GuiGpControlButtons = GuiGp.getControlButtonsForVisualCategory(param2);
         _loc3_.fallback = _loc4_;
         _loc3_.addButton(GpControlButton.START,psv_start);
         _loc3_.addButton(GpControlButton.MENU,psv_select);
      }
      
      private static function setupPs3Controls(param1:String, param2:String) : void
      {
         var _loc3_:GuiGpControlButtons = GuiGp.getControlButtonsForVisualCategory(param1);
         var _loc4_:GuiGpControlButtons = GuiGp.getControlButtonsForVisualCategory(param2);
         _loc3_.fallback = _loc4_;
         _loc3_.addButton(GpControlButton.A,ps3_cross);
         _loc3_.addButton(GpControlButton.B,ps3_circle);
         _loc3_.addButton(GpControlButton.Y,ps3_triangle);
         _loc3_.addButton(GpControlButton.X,ps3_square);
         _loc3_.addButton(GpControlButton.D_D,ps3_dpad_d);
         _loc3_.addButton(GpControlButton.D_L,ps3_dpad_l);
         _loc3_.addButton(GpControlButton.D_LD,ps3_dpad_ld);
         _loc3_.addButton(GpControlButton.D_LR,ps3_dpad_lr);
         _loc3_.addButton(GpControlButton.D_LRD,ps3_dpad_lrd);
         _loc3_.addButton(GpControlButton.D_LRU,ps3_dpad_lru);
         _loc3_.addButton(GpControlButton.D_LRUD,ps3_dpad_lrud);
         _loc3_.addButton(GpControlButton.D_LU,ps3_dpad_lu);
         _loc3_.addButton(GpControlButton.D_LUD,ps3_dpad_lud);
         _loc3_.addButton(GpControlButton.D_R,ps3_dpad_r);
         _loc3_.addButton(GpControlButton.D_RD,ps3_dpad_rd);
         _loc3_.addButton(GpControlButton.D_RU,ps3_dpad_ru);
         _loc3_.addButton(GpControlButton.D_RUD,ps3_dpad_rud);
         _loc3_.addButton(GpControlButton.D_U,ps3_dpad_u);
         _loc3_.addButton(GpControlButton.D_UD,ps3_dpad_ud);
         _loc3_.addButton(GpControlButton.L1,ps3_l1);
         _loc3_.addButton(GpControlButton.R1,ps3_r1);
         _loc3_.addButton(GpControlButton.L2,ps3_l2);
         _loc3_.addButton(GpControlButton.R2,ps3_r2);
         _loc3_.addButton(GpControlButton.L3,ps3_l3);
         _loc3_.addButton(GpControlButton.R3,ps3_r3);
         _loc3_.addButton(GpControlButton.LSTICK,ps3_lstick);
         _loc3_.addButton(GpControlButton.RSTICK,ps3_rstick);
         _loc3_.addButton(GpControlButton.LSTICK_LEFT,ps3_lstick_l);
         _loc3_.addButton(GpControlButton.LSTICK_RIGHT,ps3_lstick_r);
         _loc3_.addButton(GpControlButton.LSTICK_UP,ps3_lstick_u);
         _loc3_.addButton(GpControlButton.LSTICK_DOWN,ps3_lstick_d);
         _loc3_.addButton(GpControlButton.RSTICK_LEFT,ps3_rstick_l);
         _loc3_.addButton(GpControlButton.RSTICK_RIGHT,ps3_rstick_r);
         _loc3_.addButton(GpControlButton.RSTICK_UP,ps3_rstick_u);
         _loc3_.addButton(GpControlButton.RSTICK_DOWN,ps3_rstick_d);
         _loc3_.addButton(GpControlButton.START,ps3_start);
         _loc3_.addButton(GpControlButton.MENU,ps3_select);
         _loc3_.addButton(GpControlButton.BUTTON_CLUSTER,ps3_button_cluster);
         _loc3_.addButton(GpControlButton.DPAD,ps3_dpad_lrud);
         _loc3_.addButton(GpControlButton.POINTER,gp_pointer);
      }
      
      private static function setupXbox360Controls(param1:String, param2:String) : void
      {
         var _loc3_:GuiGpControlButtons = GuiGp.getControlButtonsForVisualCategory(param1);
         var _loc4_:GuiGpControlButtons = GuiGp.getControlButtonsForVisualCategory(param2);
         _loc3_.fallback = _loc4_;
         _loc3_.addButton(GpControlButton.A,x360_a);
         _loc3_.addButton(GpControlButton.B,x360_b);
         _loc3_.addButton(GpControlButton.Y,x360_y);
         _loc3_.addButton(GpControlButton.X,x360_x);
         _loc3_.addButton(GpControlButton.D_D,x360_dpad_d);
         _loc3_.addButton(GpControlButton.D_L,x360_dpad_l);
         _loc3_.addButton(GpControlButton.D_LD,x360_dpad_ld);
         _loc3_.addButton(GpControlButton.D_LR,x360_dpad_lr);
         _loc3_.addButton(GpControlButton.D_LRD,x360_dpad_lrd);
         _loc3_.addButton(GpControlButton.D_LRU,x360_dpad_lru);
         _loc3_.addButton(GpControlButton.D_LRUD,x360_dpad_lrud);
         _loc3_.addButton(GpControlButton.D_LU,x360_dpad_lu);
         _loc3_.addButton(GpControlButton.D_LUD,x360_dpad_lud);
         _loc3_.addButton(GpControlButton.D_R,x360_dpad_r);
         _loc3_.addButton(GpControlButton.D_RD,x360_dpad_rd);
         _loc3_.addButton(GpControlButton.D_RU,x360_dpad_ru);
         _loc3_.addButton(GpControlButton.D_RUD,x360_dpad_rud);
         _loc3_.addButton(GpControlButton.D_U,x360_dpad_u);
         _loc3_.addButton(GpControlButton.D_UD,x360_dpad_ud);
         _loc3_.addButton(GpControlButton.L1,x360_lb);
         _loc3_.addButton(GpControlButton.R1,x360_rb);
         _loc3_.addButton(GpControlButton.L2,x360_lt);
         _loc3_.addButton(GpControlButton.R2,x360_rt);
         _loc3_.addButton(GpControlButton.L3,x360_l3);
         _loc3_.addButton(GpControlButton.R3,x360_r3);
         _loc3_.addButton(GpControlButton.LSTICK,x360_lstick);
         _loc3_.addButton(GpControlButton.RSTICK,x360_rstick);
         _loc3_.addButton(GpControlButton.LSTICK_LEFT,x360_lstick_l);
         _loc3_.addButton(GpControlButton.LSTICK_RIGHT,x360_lstick_r);
         _loc3_.addButton(GpControlButton.LSTICK_UP,x360_lstick_u);
         _loc3_.addButton(GpControlButton.LSTICK_DOWN,x360_lstick_d);
         _loc3_.addButton(GpControlButton.RSTICK_LEFT,x360_rstick_l);
         _loc3_.addButton(GpControlButton.RSTICK_RIGHT,x360_rstick_r);
         _loc3_.addButton(GpControlButton.RSTICK_UP,x360_rstick_u);
         _loc3_.addButton(GpControlButton.RSTICK_DOWN,x360_rstick_d);
         _loc3_.addButton(GpControlButton.START,x360_start);
         _loc3_.addButton(GpControlButton.MENU,x360_back);
         _loc3_.addButton(GpControlButton.BUTTON_CLUSTER,x360_button_cluster);
         _loc3_.addButton(GpControlButton.DPAD,x360_dpad_lrud);
         _loc3_.addButton(GpControlButton.POINTER,gp_pointer);
      }
      
      private static function setupXboControls(param1:String, param2:String) : void
      {
         var _loc3_:GuiGpControlButtons = GuiGp.getControlButtonsForVisualCategory(param1);
         var _loc4_:GuiGpControlButtons = GuiGp.getControlButtonsForVisualCategory(param2);
         _loc3_.fallback = _loc4_;
         _loc3_.addButton(GpControlButton.D_D,xbo_dpad_d);
         _loc3_.addButton(GpControlButton.D_L,xbo_dpad_l);
         _loc3_.addButton(GpControlButton.D_LD,xbo_dpad_ld);
         _loc3_.addButton(GpControlButton.D_LR,xbo_dpad_lr);
         _loc3_.addButton(GpControlButton.D_LRD,xbo_dpad_lrd);
         _loc3_.addButton(GpControlButton.D_LRU,xbo_dpad_lru);
         _loc3_.addButton(GpControlButton.D_LRUD,xbo_dpad_lrud);
         _loc3_.addButton(GpControlButton.D_LU,xbo_dpad_lu);
         _loc3_.addButton(GpControlButton.D_LUD,xbo_dpad_lud);
         _loc3_.addButton(GpControlButton.D_R,xbo_dpad_r);
         _loc3_.addButton(GpControlButton.D_RD,xbo_dpad_rd);
         _loc3_.addButton(GpControlButton.D_RU,xbo_dpad_ru);
         _loc3_.addButton(GpControlButton.D_RUD,xbo_dpad_rud);
         _loc3_.addButton(GpControlButton.D_U,xbo_dpad_u);
         _loc3_.addButton(GpControlButton.D_UD,xbo_dpad_ud);
         _loc3_.addButton(GpControlButton.START,xbo_start);
         _loc3_.addButton(GpControlButton.MENU,xbo_back);
         _loc3_.addButton(GpControlButton.BUTTON_CLUSTER,xbo_button_cluster);
         _loc3_.addButton(GpControlButton.DPAD,xbo_dpad_lrud);
      }
      
      public static function initializeGuis(param1:Boolean, param2:ILogger) : void
      {
         LocaleFont.init();
         setupPs3Controls("ps3",null);
         setupPs4Controls("ps4","ps3");
         setupPsvControls("psv","ps3");
         setupXbox360Controls("x360",null);
         setupXboControls("xbo","x360");
         setupSwitchControls("switch",null);
         GuiCaption.mcClazz = checkGuiClass(param1,gui_caption,param2);
         SagaStartPage.mcClazz = checkGuiClass(param1,saga_start,param2);
         SagaStartPage.mcClazz_SurvivalPitchPopup = checkGuiClass(param1,survival_dlc_popup,param2);
         SagaNewGamePage.mcClazz_newGame_saga2 = checkGuiClass(param1,saga2_newgame,param2);
         SagaNewGamePage.mcClazz_newGame_saga3 = checkGuiClass(param1,saga3_newgame,param2);
         SagaSurvivalStartPage.mcClazz_survivalStart = checkGuiClass(param1,saga2_survival_start,param2);
         SagaSurvivalWinPage.mcClazz_survivalWin = checkGuiClass(param1,saga2_survival_win,param2);
         SaveLoadPage.mcClazz = checkGuiClass(param1,save_saveload,param2);
         SagaPairingPrompt.mcClazz = checkGuiClass(param1,saga_pairing_prompt,param2);
         GameDevPanel.mcClazz = checkGuiClass(param1,devpanel,param2);
         GameDownloadingSprite.mcClazz = checkGuiClass(param1,dialog_download,param2);
         ScenePageBattleVfx.mcClazz_renown = vfx_earn_renown;
         ScenePageBattleVfx.mcClazz_survivalDied = vfx_survival_died;
         ScenePageBattleVfx.mcClazz_survivalItem = vfx_item;
         SaveProfilePage.mcClazz = checkGuiClass(param1,save_profile,param2);
         SagaOptionsPage.mcOptionsClazz = checkGuiClass(param1,saga_options,param2);
         SagaOptionsPage.mcDifficultyClazz = checkGuiClass(param1,difficulty,param2);
         SagaOptionsPage.mcAudioClazz = checkGuiClass(param1,opt_audio,param2);
         SagaOptionsPage.mcLangClazz = checkGuiClass(param1,lang,param2);
         SagaOptionsPage.mcGpConfigGlazz = checkGuiClass(param1,gp_config,param2);
         SagaOptionsPage.mcGpClazz = checkGuiClass(param1,saga_options_gp,param2);
         SagaOptionsPage.mcBattleObjectivesClazz = checkGuiClass(param1,opt_battle_objectives,param2);
         CreditsPage.mcClazz = checkGuiClass(param1,credits,param2);
         CreditsPage.mcSection1Clazz = checkGuiClass(param1,credits_section1,param2);
         CreditsPage.mcSection2Clazz = checkGuiClass(param1,credits_section2,param2);
         CreditsPage.mcSection3Clazz = checkGuiClass(param1,credits_section3,param2);
         CreditsPage.mcSectionBmpClazz = checkGuiClass(param1,credits_section_bmp,param2);
         ScenePageBattleInfoFlags.mcClazzMobile = checkGuiClass(param1,battle_info_flag,param2);
         ScenePageBattleInfoFlags.mcClazzProp = checkGuiClass(param1,battle_info_flag_prop,param2);
         ScenePageBattleInfoFlags.mcClazzAbsorption = checkGuiClass(param1,battle_info_flag_absorption,param2);
         GamePage.mcButtonCloseNwClazz = checkGuiClass(param1,close_button_nw,param2);
         GuiBattleObjectives.mcClazzBattleObjective = checkGuiClass(param1,battle_objective,param2);
         BattleHudPageLoadHelper.mcClazzBattleTooltip = checkGuiClass(param1,battle_tooltip,param2);
         BattleHudPagePopupLoadHelper.mcClazzEnemyPopup = checkGuiClass(param1,enemy_popup2,param2);
         BattleHudPageLoadHelper.mcClazzBattleHud = checkGuiClass(param1,battle_hud,param2);
         BattleHudPageLoadHelper.mcClazzBattleHelp = checkGuiClass(param1,battle_help_saga,param2);
         BattleHudPageLoadHelper.mcClazzBattleOptionsButton = checkGuiClass(param1,battle_options_button,param2);
         BattleHudPagePopupLoadHelper.mcClazzPropPopup = checkGuiClass(param1,prop_popup,param2);
         TutorialLayer.mcTutEyeball = checkGuiClass(param1,tut_eyeball,param2);
         TutorialLayer.mcTutArrow = checkGuiClass(param1,tut_arrow,param2);
         TutorialLayer.mcTutCheckButton = checkGuiClass(param1,tut_check_button,param2);
         TutorialLayer.mcTutBlock = checkGuiClass(param1,tut_block,param2);
         GameLoadingPage.mcLoadingSaga = checkGuiClass(param1,loading_saga,param2);
         GameLoadingPage.mcLoadingFactions = checkGuiClass(param1,loading,param2);
         GameTextBitmapGenerator.mcTextField = checkGuiClass(param1,gui_textfield,param2);
         ScenePageBattleDamageFlags.mcClazz = checkGuiClass(param1,gui_damage_flag,param2);
         GameAssetsDef.dialogClazz = checkGuiClass(param1,gui_dialog,param2);
         GuiAlertManager.mcClazz_left_red = checkGuiClass(param1,alert_banner_left_red,param2);
         GuiAlertManager.mcClazz_left_tourney = checkGuiClass(param1,alert_banner_left_tourney,param2);
         GuiAlertManager.mcClazz_right_green = checkGuiClass(param1,alert_banner_right_green,param2);
         GuiAlertManager.mcClazz_right_red = checkGuiClass(param1,alert_banner_right_red,param2);
         GuiAlertManager.mcClazz_right_tourney = checkGuiClass(param1,alert_banner_right_tourney,param2);
         SagaSurvivalBattlePopupPage.mc_clazz = checkGuiClass(param1,survival_battle_popup,param2);
         GamePageManagerAdapterSagaMarket.mcClazz = checkGuiClass(param1,saga_market,param2);
         GamePageManagerAdapterSagaHeraldry.mcClazz = checkGuiClass(param1,saga_heraldry,param2);
         GamePageManagerAdapterCartPicker.mcClazz = checkGuiClass(param1,cart_picker,param2);
         ScenePageSpeechBubbles.mcClazzSpeechieLeft = checkGuiClass(param1,gui_speak_left,param2);
         ScenePageSpeechBubbles.mcClazzSpeechieRight = checkGuiClass(param1,gui_speak_right,param2);
         TravelPageTalkies.mcClazzTalkieLeft = checkGuiClass(param1,gui_talkie_left,param2);
         TravelPageTalkies.mcClazzTalkieRight = checkGuiClass(param1,gui_talkie_right,param2);
         TravelPage.mcClazzTravelTops.push(checkGuiClass(param1,gui_travel_top,param2));
         TravelPage.mcClazzTravelTops.push(checkGuiClass(param1,gui_travel_dark_top,param2));
         TravelPage.mcClazzTravelTops.push(checkGuiClass(param1,gui_travel_top_shattered,param2));
         TravelPage.mcClazzTravelTops.push(checkGuiClass(param1,gui_travel_dark_top_shattered,param2));
         TravelPage.mcClazzTravelTopToggle = checkGuiClass(param1,gui_travel_top_toggle,param2);
         MapCampPage.mcClazzMapCamp = checkGuiClass(param1,gui_map_camp,param2);
         MapCampPage.mcClazzMapInfo = checkGuiClass(param1,map_info,param2);
         ConvoPage.mcClazz = checkGuiClass(param1,cnv_convo,param2);
         PoppeningPage.mcClazzPopppening = checkGuiClass(param1,cnv_poppening,param2);
         WarPage.mcClazzWar = checkGuiClass(param1,cnv_war,param2);
         NetworkProblemDisplay.mcClazz = checkGuiClass(param1,network_problem,param2);
         ScenePage.mcClazzCornerButtonBanner = checkGuiClass(param1,corner_btn_banner,param2);
         ScenePage.mcClazzCornerButtonHelp = checkGuiClass(param1,corner_btn_help,param2);
         BattleHudPagePopupLoadHelper.mcSelfPopup = checkGuiClass(param1,self_popup,param2);
         BattleHudPagePopupLoadHelper.mcClazzMovePopup = checkGuiClass(param1,move_popup,param2);
         BattleHudPageAbilityPopup.mcClazzAbilityPopup = checkGuiClass(param1,ability_popup,param2);
         BattleHudPageLoadHelper.mcClazzInitiative = checkGuiClass(param1,battle_initiative,param2);
         BattleHudPageRedeployHelper.mcClazzRedeployment = checkGuiClass(param1,brd_redeployment,param2);
         BattleHudPageRedeployHelper.mcClazzEntityFrame = checkGuiClass(param1,brd_order_frame,param2);
         BattleHudPageRedeployHelper.mcClazzRosterTitle = checkGuiClass(param1,btl_roster_title,param2);
         BattleHudPageLoadingOverlayHelper.mcClazzLoadingOverlay = checkGuiClass(param1,battle_redeploy_loading_popup,param2);
         BattleHudPageLoadHelper.mcClazzGoBattle = checkGuiClass(param1,btl_go_battle_text,param2);
         BattleHudPageLoadHelper.mcClazzGoWar = checkGuiClass(param1,btl_go_war_text,param2);
         BattleHudPageLoadHelper.mcClazzPillage = checkGuiClass(param1,btl_pillage_text,param2);
         BattleHudPageLoadHelper.mcClazzPillage2 = checkGuiClass(param1,btl_pillage2_text,param2);
         BattleHudPageLoadHelper.mcClazzForgeAhead = checkGuiClass(param1,btl_forgeahead_normal_gethit,param2);
         BattleHudPageLoadHelper.mcClazzForgeAheadPillage = checkGuiClass(param1,btl_forgeahead_pillage_gethit,param2);
         BattleHudPageLoadHelper.mcClazzInsult = checkGuiClass(param1,btl_insult,param2);
         BattleHudPageLoadHelper.mcClazzRespite = checkGuiClass(param1,btl_wave_respite,param2);
         BattleHudPageLoadHelper.mcClazzReinforcements = checkGuiClass(param1,btl_wave_reinforcements,param2);
         BattleHudPageLoadHelper.mcClazzEnemyReinforcements = checkGuiClass(param1,btl_wave_enemy_reinforcements,param2);
         HornHelper.mcClazz = checkGuiClass(param1,gui_horn,param2);
         ValkaSpearHelper.mcSpearClazz = checkGuiClass(param1,gui_valka_spear,param2);
         AssembleHeroesPage.mcClazz = checkGuiClass(param1,proving_grounds,param2);
         GuiCharacterIconSlot.mcStatTooltipClazz = checkGuiClass(param1,stat_tooltip,param2);
         HeroesPage.mcClazz = checkGuiClass(param1,proving_grounds,param2);
         HeroesPage.mcClazzAblPop = checkGuiClass(param1,pg_abl_pop2,param2);
         ProvingGroundsPage.mcClazz = checkGuiClass(param1,proving_grounds,param2);
         ProvingGroundsPage.mcClazzAblPop = checkGuiClass(param1,pg_abl_pop2,param2);
         MatchResolutionPage.mcClazz = checkGuiClass(param1,match_resolution,param2);
         WarResolutionPage.mcClazz = checkGuiClass(param1,match_resolution,param2);
         TallyPage.mcClazzTallyText = checkGuiClass(param1,tally_text,param2);
         TallyPage.mcClazzTallyNumber = checkGuiClass(param1,tally_number,param2);
         TallyPage.mcClazzTallyBanner = checkGuiClass(param1,darkness_transition,param2);
         GuiGpConfig.mcClazz_state = gpc_state;
         SagaStartPage.mcClazz_SagaNews = checkGuiClass(param1,start_news,param2);
         SagaStartPage.mcClazz_SagaNewsToggle = checkGuiClass(param1,gui_news_toggle,param2);
         SagaSelectorPage.mcClazz = checkGuiClass(param1,saga_selector_12,param2);
      }
   }
}

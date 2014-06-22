<!-- Improvements made by Douglas Bumby -->
<?php
$hp_realtime_on = false;
/* This image will be used for sharing on Facebook, it should be a square */
if ( function_exists( 'add_theme_support' ) ) {
  add_theme_support( 'post-thumbnails' );
	set_post_thumbnail_size( 140 , 140 ); //Default post thumbnail size
}

//Get javascript dependencies loaded
function aarseth_scripts()
{
	global $hp_realtime_on;
	//JQuery
	wp_deregister_script( 'jquery' );
    wp_register_script( 'jquery', 'http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js');
    wp_enqueue_script( 'jquery' );

	//Handlebars
	wp_enqueue_script( 'handlebars',
	get_bloginfo( 'stylesheet_directory' ) . '/js/handlebars.js',
	null,
	null,
	false );

	if( $hp_realtime_on )
	{
		//Pubnub
		wp_enqueue_script( 'pubnub' ,
			'http://cdn.pubnub.com/pubnub-3.3.min.js',
			null,
			null,
			true );

		//Pubnub listener and template parser
		wp_enqueue_script('post_listener' ,
			get_bloginfo( 'stylesheet_directory' ) . '/js/new_post_listener.js',
			null,
			null,
			true );
	}

	if( is_home() )
	{
	//Infinite scroll script
		wp_enqueue_script('infinite_scroll' ,
			get_bloginfo( 'stylesheet_directory' ) . '/js/infinite_scroll.js',
			null,
			null,
			true );
	}
}
add_action('wp_enqueue_scripts', 'aarseth_scripts');

//Load up the real-time posting script
if( $hp_realtime_on )
	require_once('includes/realtime.php');

/* Create theme options:
 * - Facebook app id for comments - fb_app_id
 * - Facebook user id - fb_user_id
 * - Header text (accepts HTML) - site_description
 * - Facebook Page or profile (Subscribe vs like) -
 * - Twitter username
 * - Copyright by - copyright
 * - RSS URL -
 * - Logo - logo
 * - Google Analytics - google_analytics
 * - End of post call to action - post_cta
 */

add_action( 'admin_init', 'hp_options_init' );
add_action( 'admin_menu', 'hp_options_add_page' );

/**
 * Init plugin options to white list our options
 */
function hp_options_init(){
	register_setting( 'aarseth_options' , 'hp_options', 'aarseth_options_validate'  );
	//register_setting( 'aarseth_options' , 'facebook_url' , 'aarseth_options_validate'  );
	//register_setting( 'aarseth_options' , 'fb_page_or_profile' , 'aarseth_options_validate'  ); //Set whether or not the FB url is page or profile
	//register_setting( 'aarseth_options' , 'twitter_username' , 'aarseth_options_validate'  );
	//register_setting( 'aarseth_options' , 'rss_url' , 'aarseth_options_validate'  );
	//register_setting( 'aarseth_options' , 'logo_url' , 'aarseth_options_validate'  );
}

/**
 * Load up the menu page
 */
function hp_options_add_page() {
	add_theme_page( __( 'aarseth Options', 'aarseth_theme' ), __( 'aarseth Options', 'aarseth_theme' ), 'edit_theme_options', 'hp_options', 'hp_options_do_page' );
}

/**
 * Create the options page
 */
function hp_options_do_page() {

	if ( ! isset( $_REQUEST['settings-updated'] ) )
		$_REQUEST['settings-updated'] = false;

	?>
	<div class="wrap">
		<?php screen_icon(); echo "<h2>" . wp_get_theme() . __( ' Theme Options', 'aarseth_theme' ) . "</h2>"; ?>

		<?php if ( false !== $_REQUEST['settings-updated'] ) : ?>
		<div class="updated fade"><p><strong><?php _e( 'Options saved', 'aarseth_theme' ); ?></strong></p></div>
		<?php endif; ?>

		<form method="post" action="options.php">
			<?php settings_fields( 'aarseth_options' ); ?>
			<?php $options = get_option( 'hp_options' ); ?>

			<table class="form-table">
				<!-- Site description html -->
				<tr valign="top"><th scope="row"><?php _e( 'Site description', 'aarseth_theme' ); ?></th>
					<td>
						<input id="hp_options[site_description]" class="regular-text" type="text" name="hp_options[site_description]" value="<?php esc_attr_e( $options['site_description'] ); ?>" />
						<label class="description" for="hp_options[site_description]"><?php _e( 'Enter the description that will sit at the top of the site. (HTML optional)', 'aarseth_theme' ); ?></label>
					</td>
				</tr>

				<!-- Facebook App ID for comments -->
				<tr valign="top"><th scope="row"><?php _e( 'Facebook App ID', 'aarseth_theme' ); ?></th>
					<td>
						<input id="hp_options[fb_app_id]" class="regular-text" type="text" name="hp_options[fb_app_id]" value="<?php esc_attr_e( $options['fb_app_id'] ); ?>" />
						<label class="description" for="hp_options[fb_app_id]"><?php _e( 'Enter your Facebook App ID', 'aarseth_theme' ); ?></label>
					</td>
				</tr>

				<!-- Copyright tag -->
				<tr valign="top"><th scope="row"><?php _e( 'Copyright tag', 'aarseth_theme' ); ?></th>
					<td>
						<input id="hp_options[copyright]" class="regular-text" type="text" name="hp_options[copyright]" value="<?php esc_attr_e( $options['copyright'] ); ?>" />
						<label class="description" for="hp_options[copyright]"><?php _e( 'This is the text that will be displayed after the copyright tag.', 'aarseth_theme' ); ?></label>
					</td>
				</tr>

				<!-- Google Analytics Tag -->
				<tr valign="top"><th scope="row"><?php _e( 'Google Analytics Tag', 'aarseth_theme' ); ?></th>
					<td>
						<input id="hp_options[google_analytics]" class="regular-text" type="text" name="hp_options[google_analytics]" value="<?php esc_attr_e( $options['google_analytics'] ); ?>" />
						<label class="description" for="hp_options[google_analytics]"><?php _e( 'Your Google Analytics account. (e.g. UA-XXXXXXXXX-X)', 'aarseth_theme' ); ?></label>
					</td>
				</tr>

				<!-- Logo -->
				<tr valign="top"><th scope="row"><?php _e( 'Logo', 'aarseth_theme' ); ?></th>
					<td>
						<input id="hp_options[logo]" class="regular-text" type="text" name="hp_options[logo]" value="<?php esc_attr_e( $options['logo'] ); ?>" />
						<label class="description" for="hp_options[logo]"><?php _e( 'Enter a URL of your logo', 'aarseth_theme' ); ?></label>
					</td>
				</tr>

				<!-- Ads snipped -->
				<tr valign="top"><th scope="row"><?php _e( 'Ads Snippet', 'aarseth_theme' ); ?></th>
					<td>
						<input id="hp_options[ads_snipped]" class="regular-text" type="text" name="hp_options[ads_snippet]" value="<?php esc_attr_e( $options['ads_snippet'] ); ?>" />
						<label class="description" for="hp_options[ads_snippet]"><?php _e( 'Ads Snippet for ad unit up to 170 pixels wide.', 'aarseth_theme' ); ?></label>
					</td>
				</tr>

				<!-- End of post call to action -->
				<tr valign="top"><th scope="row"><?php _e( 'Post call to action', 'aarseth_theme' ); ?></th>
					<td>
						<textarea id="hp_options[post_cta]" name="hp_options[post_cta]" class="regular-text" cols="41" rows="5"><?php esc_attr_e( $options['post_cta'] ); ?></textarea>
						<label class="description" for="hp_options[post_cta]"><?php _e( 'HTML for after post call to action', 'aarseth_theme' ); ?></label>
					</td>
				</tr>
			</table>

			<p class="submit">
				<input type="submit" class="button-primary" value="<?php _e( 'Save Options', 'aarseth_theme' ); ?>" />
			</p>
		</form>
	</div>
	<?php
}

/**
 * Sanitize and validate input. Accepts an array, return a sanitized array.
 */
function theme_options_validate( $input ) {
	return $input;
}


/**
 * Sanitize and validate input. Accepts an array, return a sanitized array.
 */
function aarseth_options_validate( $input ) {

	//$input['aweber_list'] = wp_filter_nohtml_kses( $input['aweber_list'] );
	return $input;
}

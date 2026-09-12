import 'subscription_category.dart';
import 'tracked_category.dart';

class CatalogApp {
  const CatalogApp(this.name, this.logoAsset, this.category);

  final String name;
  final String logoAsset;
  final TrackedCategory category;
}

const _entertainment = SubscriptionCategories.entertainment;
const _ai = SubscriptionCategories.ai;
const _productivity = SubscriptionCategories.productivity;
const _cloudStorage = SubscriptionCategories.cloudStorage;
const _education = SubscriptionCategories.education;
const _shoppingDelivery = SubscriptionCategories.shoppingDelivery;
const _other = SubscriptionCategories.other;

const List<CatalogApp> subscriptionCatalog = [
  CatalogApp('Netflix', 'lib/assets/logos/Netflix_icon.svg', _entertainment),
  CatalogApp(
      'ChatGPT Plus',
      'lib/assets/logos/chatgpt-logo-chat-gpt-icon-on-white-background-free-vector.jpg',
      _ai),
  CatalogApp('Duolingo', 'lib/assets/logos/doulingo.webp', _education),
  CatalogApp('Spotify', 'lib/assets/logos/Spotify_App_Logo.svg.webp', _entertainment),
  CatalogApp('Apple Music', 'lib/assets/logos/Apple_Music_icon.svg.webp', _entertainment),
  CatalogApp('Apple TV+', 'lib/assets/logos/apple-tv-logo-png_seeklogo-314167.png',
      _entertainment),
  CatalogApp('Amazon Prime Video',
      'lib/assets/logos/Amazon-Prime-Video-Logo-PNG-Cutout-thumb.webp', _entertainment),
  CatalogApp('Disney+', 'lib/assets/logos/disney.webp', _entertainment),
  CatalogApp(
      'YouTube Premium',
      'lib/assets/logos/white-square-bordered-youtube-logo-on-transparent-background-free-png.webp',
      _entertainment),
  CatalogApp('Twitch', 'lib/assets/logos/twitch.png', _entertainment),
  CatalogApp('SoundCloud', 'lib/assets/logos/soundcloud-logo_578229-231.png', _entertainment),
  CatalogApp('Anghami', 'lib/assets/logos/anghami.png', _entertainment),
  CatalogApp('Shahid VIP', 'lib/assets/logos/shahid.png', _entertainment),
  CatalogApp('OSN+', 'lib/assets/logos/osn-logo-png_seeklogo-629451.png', _entertainment),
  CatalogApp('StarzPlay', 'lib/assets/logos/20241007-starzplay-logo.webp', _entertainment),
  CatalogApp('Thmanya', 'lib/assets/logos/thamanya.jpg', _entertainment),
  CatalogApp('noon', 'lib/assets/logos/noon-com-logo-png_seeklogo-467329.png',
      _shoppingDelivery),
  CatalogApp('Snapchat+', 'lib/assets/logos/snapchat.png', _entertainment),
  CatalogApp('X Premium', 'lib/assets/logos/x.png', _entertainment),
  CatalogApp('Xbox Game Pass', 'lib/assets/logos/xbox.png', _entertainment),
  CatalogApp('PlayStation Plus',
      'lib/assets/logos/playstation-plus-logo-png_seeklogo-411713.png', _entertainment),
  CatalogApp('Nintendo Switch Online', 'lib/assets/logos/nintendo.png', _entertainment),
  CatalogApp('Claude', 'lib/assets/logos/claude.webp', _ai),
  CatalogApp('Gemini', 'lib/assets/logos/gemini-color.png', _ai),
  CatalogApp('Perplexity', 'lib/assets/logos/perplexity-ai-icon.webp', _ai),
  CatalogApp(
      'Midjourney', 'lib/assets/logos/midjourney-logo-png_seeklogo-501203.png', _ai),
  CatalogApp('Poe', 'lib/assets/logos/poe.png', _ai),
  CatalogApp('Jasper AI', 'lib/assets/logos/jasper.png', _ai),
  CatalogApp('ElevenLabs', 'lib/assets/logos/elevenlabs.png', _ai),
  CatalogApp('Runway', 'lib/assets/logos/Runway.webp', _ai),
  CatalogApp('Character.AI', 'lib/assets/logos/char ai logo.jpeg', _ai),
  CatalogApp('GitHub Copilot', 'lib/assets/logos/github-copilot.webp', _ai),
  CatalogApp('GitHub', 'lib/assets/logos/github_logo_icon_229278.webp', _productivity),
  CatalogApp('Cursor', 'lib/assets/logos/cursor.png', _productivity),
  CatalogApp('Figma', 'lib/assets/logos/figma.png', _productivity),
  CatalogApp('Canva', 'lib/assets/logos/canva.jpeg', _productivity),
  CatalogApp('Notion', 'lib/assets/logos/notion.webp', _productivity),
  CatalogApp('Evernote', 'lib/assets/logos/evernote.png', _productivity),
  CatalogApp('Notability', 'lib/assets/logos/Notability_Icon_Vectorized.svg.webp',
      _education),
  CatalogApp('TickTick', 'lib/assets/logos/ticktick.png', _productivity),
  CatalogApp('Todoist', 'lib/assets/logos/todoist-icon.webp', _productivity),
  CatalogApp('Trello', 'lib/assets/logos/trello.jpeg', _productivity),
  CatalogApp('Asana', 'lib/assets/logos/asana.svg', _productivity),
  CatalogApp('Calendly', 'lib/assets/logos/callendly.png', _productivity),
  CatalogApp('Slack', 'lib/assets/logos/Slack_icon_2019.svg.webp', _productivity),
  CatalogApp(
      'Zoom',
      'lib/assets/logos/zoom-logo-in-blue-colors-meetings-app-logotype-illustration-free-png.webp',
      _productivity),
  CatalogApp('Dropbox', 'lib/assets/logos/dropbox.png', _cloudStorage),
  CatalogApp('OneDrive', 'lib/assets/logos/onedrive.jpeg', _cloudStorage),
  CatalogApp('Google One', 'lib/assets/logos/google1.png', _cloudStorage),
  CatalogApp('Google Workspace', 'lib/assets/logos/google workspace.jpeg', _productivity),
  CatalogApp('Microsoft 365', 'lib/assets/logos/microsoft365.png', _productivity),
  CatalogApp('Adobe Creative Cloud',
      'lib/assets/logos/Adobe_Creative_Cloud_rainbow_icon.svg', _productivity),
  CatalogApp('Adobe Acrobat', 'lib/assets/logos/Adobe_Acrobat_DC_logo_2020.svg.webp',
      _productivity),
  CatalogApp('Grammarly', 'lib/assets/logos/grammarly-icon.webp', _productivity),
  CatalogApp('QuillBot', 'lib/assets/logos/quillbot.jpeg', _ai),
  CatalogApp('1Password', 'lib/assets/logos/1password.jpeg', _other),
  CatalogApp('Dashlane', 'lib/assets/logos/dashline.png', _other),
  CatalogApp('NordVPN', 'lib/assets/logos/nordvpn.jpg', _other),
  CatalogApp('ExpressVPN', 'lib/assets/logos/express vpn.png', _other),
  CatalogApp('Audible', 'lib/assets/logos/audible.png', _education),
  CatalogApp('Kindle Unlimited', 'lib/assets/logos/kindle.png', _education),
  CatalogApp('iCloud+', 'lib/assets/logos/icloud+.png', _cloudStorage),
  CatalogApp('HungerStation', 'lib/assets/logos/hungerstation.png', _shoppingDelivery),
  CatalogApp('Jahez', 'lib/assets/logos/jahez.png', _shoppingDelivery),
  CatalogApp('STC', 'lib/assets/logos/stc.jpeg', _other),
  CatalogApp('Mobily', 'lib/assets/logos/mobily.png', _other),
  CatalogApp('Zain', 'lib/assets/logos/zain.png', _other),
];

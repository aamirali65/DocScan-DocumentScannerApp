import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/constants.dart';

class AdService {
  static bool _initialized = false;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isInterstitialLoading = false;
  bool _isRewardedLoading = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
    } catch (e) {
      debugPrint('AdMob init failed (ads disabled): $e');
    }
  }

  bool get isAvailable => _initialized;

  Future<void> loadInterstitial() async {
    if (!_initialized || _isInterstitialLoading) return;
    _isInterstitialLoading = true;

    try {
      await InterstitialAd.load(
        adUnitId: AppConstants.adInterstitialId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isInterstitialLoading = false;
          },
          onAdFailedToLoad: (error) {
            _isInterstitialLoading = false;
          },
        ),
      );
    } catch (_) {
      _isInterstitialLoading = false;
    }
  }

  Future<bool> showInterstitial() async {
    if (_interstitialAd == null || !_initialized) return false;
    try {
      final completer = Completer<bool>();
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          completer.complete(true);
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          completer.complete(false);
        },
      );
      await _interstitialAd!.show();
      return completer.future;
    } catch (_) {
      return false;
    }
  }

  Future<void> loadRewarded() async {
    if (!_initialized || _isRewardedLoading) return;
    _isRewardedLoading = true;

    try {
      await RewardedAd.load(
        adUnitId: AppConstants.adRewardedId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isRewardedLoading = false;
          },
          onAdFailedToLoad: (error) {
            _isRewardedLoading = false;
          },
        ),
      );
    } catch (_) {
      _isRewardedLoading = false;
    }
  }

  Future<bool> showRewarded() async {
    if (_rewardedAd == null || !_initialized) return false;
    try {
      final completer = Completer<bool>();
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedAd = null;
          completer.complete(true);
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _rewardedAd = null;
          completer.complete(false);
        },
      );
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          completer.complete(true);
        },
      );
      return completer.future;
    } catch (_) {
      return false;
    }
  }

  BannerAd? createBannerAd() {
    if (!_initialized) return null;
    try {
      return BannerAd(
        adUnitId: AppConstants.adBannerId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) {},
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
          },
        ),
      );
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}

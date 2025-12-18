#!/usr/bin/env python3
"""
App Store Connect Subscription Setup Script
Configures iOS subscriptions via App Store Connect API

Product IDs:
- Yearly (with 3-day free trial): everyday_christian_ios_yearly_sub
- Monthly (no trial): everyday_christian_ios_monthly_sub
"""

import jwt
import time
import requests
import json
from datetime import datetime, timedelta
from pathlib import Path

class AppStoreConnectAPI:
    """App Store Connect API client"""

    def __init__(self, key_id, issuer_id, private_key_path):
        self.key_id = key_id
        self.issuer_id = issuer_id
        self.private_key_path = private_key_path
        self.base_url = "https://api.appstoreconnect.apple.com"

    def generate_token(self):
        """Generate JWT token for API authentication"""
        with open(self.private_key_path, 'r') as f:
            private_key = f.read()

        headers = {
            "alg": "ES256",
            "kid": self.key_id,
            "typ": "JWT"
        }

        payload = {
            "iss": self.issuer_id,
            "iat": int(time.time()),
            "exp": int(time.time()) + 20 * 60,  # 20 minutes
            "aud": "appstoreconnect-v1"
        }

        token = jwt.encode(payload, private_key, algorithm="ES256", headers=headers)
        return token

    def make_request(self, method, endpoint, data=None):
        """Make authenticated API request"""
        token = self.generate_token()
        headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json"
        }

        url = f"{self.base_url}{endpoint}"

        if method == "GET":
            response = requests.get(url, headers=headers)
        elif method == "POST":
            response = requests.post(url, headers=headers, json=data)
        elif method == "PATCH":
            response = requests.patch(url, headers=headers, json=data)
        elif method == "DELETE":
            response = requests.delete(url, headers=headers)

        if response.status_code >= 400:
            print(f"❌ Error {response.status_code}: {response.text}")
            response.raise_for_status()

        return response.json() if response.text else {}

    def get_app(self, bundle_id):
        """Get app by bundle ID"""
        print(f"🔍 Finding app with bundle ID: {bundle_id}")
        response = self.make_request("GET", f"/v1/apps?filter[bundleId]={bundle_id}")

        if not response.get('data'):
            raise Exception(f"App not found with bundle ID: {bundle_id}")

        app_id = response['data'][0]['id']
        print(f"✅ Found app: {app_id}")
        return app_id

    def get_or_create_subscription_group(self, app_id, group_name, reference_name):
        """Get existing subscription group or create new one"""
        print(f"📦 Looking for subscription group: {group_name}")

        # Try to get existing groups
        response = self.make_request("GET", f"/v1/apps/{app_id}/subscriptionGroups")

        if response.get('data'):
            # Use first existing group
            group_id = response['data'][0]['id']
            print(f"✅ Found existing subscription group: {group_id}")
            return group_id

        # Create new group if none exists
        print(f"📦 Creating new subscription group")
        data = {
            "data": {
                "type": "subscriptionGroups",
                "attributes": {
                    "referenceName": reference_name
                },
                "relationships": {
                    "app": {
                        "data": {
                            "type": "apps",
                            "id": app_id
                        }
                    }
                }
            }
        }

        response = self.make_request("POST", "/v1/subscriptionGroups", data)
        group_id = response['data']['id']
        print(f"✅ Created subscription group: {group_id}")
        return group_id

    def get_or_create_subscription(self, group_id, product_id, name, duration):
        """Get existing subscription or create new one"""
        print(f"📱 Looking for subscription: {product_id}")

        # Get subscriptions in group
        response = self.make_request("GET", f"/v1/subscriptionGroups/{group_id}/subscriptions")

        # Check if product_id already exists
        for sub in response.get('data', []):
            if sub['attributes'].get('productId') == product_id:
                subscription_id = sub['id']
                print(f"✅ Found existing subscription: {subscription_id}")
                return subscription_id

        # Create new subscription
        print(f"📱 Creating new subscription: {product_id}")
        data = {
            "data": {
                "type": "subscriptions",
                "attributes": {
                    "name": name,
                    "productId": product_id,
                    "subscriptionPeriod": duration,
                    "reviewNote": "Premium subscription with AI-powered scripture conversations"
                },
                "relationships": {
                    "group": {
                        "data": {
                            "type": "subscriptionGroups",
                            "id": group_id
                        }
                    }
                }
            }
        }

        response = self.make_request("POST", "/v1/subscriptions", data)
        subscription_id = response['data']['id']
        print(f"✅ Created subscription: {subscription_id}")
        return subscription_id

    def add_subscription_localization(self, subscription_id, locale, display_name, description):
        """Add localization to subscription"""
        print(f"🌍 Adding {locale} localization")

        data = {
            "data": {
                "type": "subscriptionLocalizations",
                "attributes": {
                    "locale": locale,
                    "name": display_name,
                    "description": description
                },
                "relationships": {
                    "subscription": {
                        "data": {
                            "type": "subscriptions",
                            "id": subscription_id
                        }
                    }
                }
            }
        }

        response = self.make_request("POST", "/v1/subscriptionLocalizations", data)
        print(f"✅ Added {locale} localization")
        return response['data']['id']

    def create_introductory_offer(self, subscription_id, duration=3):
        """Create introductory offer (free trial)"""
        print(f"🎁 Creating {duration}-day free trial")

        data = {
            "data": {
                "type": "subscriptionIntroductoryOffers",
                "attributes": {
                    "offerMode": "FREE_TRIAL",
                    "duration": "THREE_DAYS",  # Must be enum value, not ISO 8601
                    "numberOfPeriods": 1  # Required attribute
                },
                "relationships": {
                    "subscription": {
                        "data": {
                            "type": "subscriptions",
                            "id": subscription_id
                        }
                    }
                }
            }
        }

        response = self.make_request("POST", "/v1/subscriptionIntroductoryOffers", data)
        print(f"✅ Created free trial")
        return response['data']['id']

    def get_territories(self):
        """Get all available territories"""
        print(f"🌍 Fetching territories...")
        response = self.make_request("GET", "/v1/territories?limit=200")
        return response.get('data', [])

    def find_territory_by_code(self, code="USA"):
        """Find territory ID by country code"""
        print(f"🔍 Finding territory: {code}")
        territories = self.get_territories()

        for territory in territories:
            # Match exact territory code (USA, GBR, etc.)
            if territory['id'] == code:
                territory_id = territory['id']
                print(f"✅ Found territory: {territory_id}")
                return territory_id

        raise Exception(f"Territory {code} not found")

    def get_subscription_price_points(self, subscription_id):
        """Get available price points for a subscription"""
        print(f"💰 Fetching price points for subscription...")
        response = self.make_request("GET", f"/v1/subscriptions/{subscription_id}/pricePoints?limit=200")
        return response.get('data', [])

    def find_price_point_for_amount(self, subscription_id, target_price):
        """Find price point ID that matches target price"""
        print(f"🔍 Looking for price point matching ${target_price}...")

        price_points = self.get_subscription_price_points(subscription_id)

        # Search for matching price
        for pp in price_points:
            # Price points have customerPrice attribute
            customer_price = pp.get('attributes', {}).get('customerPrice')
            if customer_price and abs(float(customer_price) - float(target_price)) < 0.01:
                pp_id = pp['id']
                print(f"✅ Found price point: {pp_id} (${customer_price})")
                return pp_id

        print(f"⚠️  No exact price point found for ${target_price}")
        print(f"   Available price points:")
        for pp in price_points[:10]:  # Show first 10
            cp = pp.get('attributes', {}).get('customerPrice', 'N/A')
            print(f"     - {pp['id']}: ${cp}")

        return None

    def set_subscription_price(self, subscription_id, price_usd, territory_code="USA"):
        """Set subscription price via API"""
        print(f"💰 Setting price: ${price_usd}")

        try:
            # Get territory
            territory_id = self.find_territory_by_code(territory_code)

            # Find matching price point
            price_point_id = self.find_price_point_for_amount(subscription_id, price_usd)

            if not price_point_id:
                print(f"⚠️  Cannot set price automatically - price point not found")
                print(f"   You must set pricing manually in App Store Connect")
                print(f"   Target price: ${price_usd} USD")
                return None

            # Create subscription price
            data = {
                "data": {
                    "type": "subscriptionPrices",
                    "relationships": {
                        "subscription": {
                            "data": {
                                "type": "subscriptions",
                                "id": subscription_id
                            }
                        },
                        "territory": {
                            "data": {
                                "type": "territories",
                                "id": territory_id
                            }
                        },
                        "subscriptionPricePoint": {
                            "data": {
                                "type": "subscriptionPricePoints",
                                "id": price_point_id
                            }
                        }
                    }
                }
            }

            response = self.make_request("POST", "/v1/subscriptionPrices", data)
            print(f"✅ Price set successfully: ${price_usd}")
            return response['data']['id']

        except Exception as e:
            if "409" in str(e):
                print(f"ℹ️  Price already set for this territory")
            else:
                print(f"⚠️  Error setting price: {e}")
                print(f"   You may need to set pricing manually in App Store Connect")
                print(f"   Target price: ${price_usd} USD")


def main():
    """Main setup function"""
    print("=" * 60)
    print("App Store Connect Subscription Setup")
    print("=" * 60)
    print()

    # These will be provided by user
    KEY_ID = input("Enter Key ID: ").strip()
    ISSUER_ID = input("Enter Issuer ID: ").strip()
    PRIVATE_KEY_PATH = input("Enter path to private key (.p8 file): ").strip()
    BUNDLE_ID = "com.elev8tion.everydaychristian"  # Your bundle ID

    print()
    print("🔐 Authenticating with App Store Connect...")
    api = AppStoreConnectAPI(KEY_ID, ISSUER_ID, PRIVATE_KEY_PATH)

    try:
        # Get app
        app_id = api.get_app(BUNDLE_ID)

        # Get or create subscription group
        group_id = api.get_or_create_subscription_group(
            app_id,
            group_name="Premium Subscription",
            reference_name="premium_subscription"
        )

        print()
        print("=" * 60)
        print("Creating Yearly Subscription (with 3-day free trial)")
        print("=" * 60)

        # Get or create yearly subscription
        yearly_sub_id = api.get_or_create_subscription(
            group_id,
            product_id="everyday_christian_ios_yearly_sub",
            name="Premium Annual",
            duration="ONE_YEAR"
        )

        # Add English localization for yearly
        try:
            api.add_subscription_localization(
                yearly_sub_id,
                locale="en-US",
                display_name="Premium - Annual",
                description="150 AI chats/month, all features"
            )
        except Exception as e:
            if "409" in str(e):
                print("ℹ️  en-US localization already exists")
            else:
                raise

        # Add Spanish localization for yearly
        try:
            api.add_subscription_localization(
                yearly_sub_id,
                locale="es-ES",
                display_name="Premium - Anual",
                description="150 chats IA/mes, todas las funciones"
            )
        except Exception as e:
            if "409" in str(e):
                print("ℹ️  es-ES localization already exists")
            else:
                raise

        # Add 3-day free trial (ONLY for yearly)
        try:
            api.create_introductory_offer(yearly_sub_id, duration=3)
        except Exception as e:
            if "409" in str(e):
                print("ℹ️  Free trial already exists")
            else:
                raise

        # Set price
        api.set_subscription_price(yearly_sub_id, price_usd=35.99)

        print()
        print("=" * 60)
        print("Creating Monthly Subscription (NO free trial)")
        print("=" * 60)

        # Get or create monthly subscription (NO FREE TRIAL)
        monthly_sub_id = api.get_or_create_subscription(
            group_id,
            product_id="everyday_christian_ios_monthly_sub",
            name="Premium Monthly",
            duration="ONE_MONTH"
        )

        # Add English localization for monthly
        try:
            api.add_subscription_localization(
                monthly_sub_id,
                locale="en-US",
                display_name="Premium - Monthly",
                description="150 AI chats/month, all features"
            )
        except Exception as e:
            if "409" in str(e):
                print("ℹ️  en-US localization already exists")
            else:
                raise

        # Add Spanish localization for monthly
        try:
            api.add_subscription_localization(
                monthly_sub_id,
                locale="es-ES",
                display_name="Premium - Mensual",
                description="150 chats IA/mes, todas las funciones"
            )
        except Exception as e:
            if "409" in str(e):
                print("ℹ️  es-ES localization already exists")
            else:
                raise

        # NO free trial for monthly
        print("ℹ️  No free trial for monthly subscription (as specified)")

        # Set price
        api.set_subscription_price(monthly_sub_id, price_usd=5.99)

        print()
        print("=" * 60)
        print("✅ SUCCESS! Subscriptions configured")
        print("=" * 60)
        print()
        print("📋 Summary:")
        print(f"   Yearly: everyday_christian_ios_yearly_sub")
        print(f"           ✅ 3-day free trial")
        print(f"           ✅ English + Spanish")
        print(f"           💰 $35.99/year")
        print()
        print(f"   Monthly: everyday_christian_ios_monthly_sub")
        print(f"            ❌ No free trial")
        print(f"            ✅ English + Spanish")
        print(f"            💰 $5.99/month")
        print()
        print("⚠️  Next steps:")
        print("   1. Upload App Review Screenshots in App Store Connect")
        print("   2. Verify pricing is correct")
        print("   3. Submit subscriptions with your app build")

    except Exception as e:
        print(f"❌ Error: {e}")
        raise


if __name__ == "__main__":
    main()

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
// EXTRA BEGIN
typedef struct DartCObject *WireSyncRust2DartDco;
typedef struct WireSyncRust2DartSse {
  uint8_t *ptr;
  int32_t len;
} WireSyncRust2DartSse;

typedef int64_t DartPort;
typedef bool (*DartPostCObjectFnType)(DartPort port_id, void *message);
void store_dart_post_cobject(DartPostCObjectFnType ptr);
// EXTRA END
typedef struct _Dart_Handle* Dart_Handle;

typedef struct wire_cst_list_prim_u_8_strict {
  uint8_t *ptr;
  int32_t len;
} wire_cst_list_prim_u_8_strict;

typedef struct wire_cst_list_String {
  struct wire_cst_list_prim_u_8_strict **ptr;
  int32_t len;
} wire_cst_list_String;

typedef struct wire_cst_group_children_list {
  struct wire_cst_list_prim_u_8_strict *group_id;
  struct wire_cst_list_prim_u_8_strict *time;
  struct wire_cst_list_prim_u_8_strict *parent;
} wire_cst_group_children_list;

typedef struct wire_cst_list_group_children_list {
  struct wire_cst_group_children_list *ptr;
  int32_t len;
} wire_cst_list_group_children_list;

typedef struct wire_cst_group_invite_req_list {
  struct wire_cst_list_prim_u_8_strict *group_id;
  struct wire_cst_list_prim_u_8_strict *time;
} wire_cst_group_invite_req_list;

typedef struct wire_cst_list_group_invite_req_list {
  struct wire_cst_group_invite_req_list *ptr;
  int32_t len;
} wire_cst_list_group_invite_req_list;

typedef struct wire_cst_group_join_req_list {
  struct wire_cst_list_prim_u_8_strict *user_id;
  struct wire_cst_list_prim_u_8_strict *time;
  int32_t user_type;
} wire_cst_group_join_req_list;

typedef struct wire_cst_list_group_join_req_list {
  struct wire_cst_group_join_req_list *ptr;
  int32_t len;
} wire_cst_list_group_join_req_list;

typedef struct wire_cst_group_user_list_item {
  struct wire_cst_list_prim_u_8_strict *user_id;
  int32_t rank;
  struct wire_cst_list_prim_u_8_strict *joined_time;
  int32_t user_type;
} wire_cst_group_user_list_item;

typedef struct wire_cst_list_group_user_list_item {
  struct wire_cst_group_user_list_item *ptr;
  int32_t len;
} wire_cst_list_group_user_list_item;

typedef struct wire_cst_list_groups {
  struct wire_cst_list_prim_u_8_strict *group_id;
  struct wire_cst_list_prim_u_8_strict *time;
  struct wire_cst_list_prim_u_8_strict *joined_time;
  int32_t rank;
  struct wire_cst_list_prim_u_8_strict *parent;
} wire_cst_list_groups;

typedef struct wire_cst_list_list_groups {
  struct wire_cst_list_groups *ptr;
  int32_t len;
} wire_cst_list_list_groups;

typedef struct wire_cst_user_device_list {
  struct wire_cst_list_prim_u_8_strict *device_id;
  struct wire_cst_list_prim_u_8_strict *time;
  struct wire_cst_list_prim_u_8_strict *device_identifier;
} wire_cst_user_device_list;

typedef struct wire_cst_list_user_device_list {
  struct wire_cst_user_device_list *ptr;
  int32_t len;
} wire_cst_list_user_device_list;

typedef struct wire_cst_claims {
  struct wire_cst_list_prim_u_8_strict *aud;
  struct wire_cst_list_prim_u_8_strict *sub;
  uintptr_t exp;
  uintptr_t iat;
  bool fresh;
} wire_cst_claims;

typedef struct wire_cst_device_key_data {
  struct wire_cst_list_prim_u_8_strict *private_key;
  struct wire_cst_list_prim_u_8_strict *public_key;
  struct wire_cst_list_prim_u_8_strict *sign_key;
  struct wire_cst_list_prim_u_8_strict *verify_key;
  struct wire_cst_list_prim_u_8_strict *exported_public_key;
  struct wire_cst_list_prim_u_8_strict *exported_verify_key;
} wire_cst_device_key_data;

typedef struct wire_cst_generated_register_data {
  struct wire_cst_list_prim_u_8_strict *identifier;
  struct wire_cst_list_prim_u_8_strict *password;
} wire_cst_generated_register_data;

typedef struct wire_cst_group_out_data_light_export {
  struct wire_cst_list_prim_u_8_strict *group_id;
  struct wire_cst_list_prim_u_8_strict *parent_group_id;
  int32_t rank;
  struct wire_cst_list_prim_u_8_strict *created_time;
  struct wire_cst_list_prim_u_8_strict *joined_time;
  struct wire_cst_list_prim_u_8_strict *access_by_group_as_member;
  struct wire_cst_list_prim_u_8_strict *access_by_parent_group;
  bool is_connected_group;
} wire_cst_group_out_data_light_export;

typedef struct wire_cst_otp_recovery_keys_output {
  struct wire_cst_list_String *keys;
} wire_cst_otp_recovery_keys_output;

typedef struct wire_cst_otp_register {
  struct wire_cst_list_prim_u_8_strict *secret;
  struct wire_cst_list_prim_u_8_strict *alg;
  struct wire_cst_list_String *recover;
} wire_cst_otp_register;

typedef struct wire_cst_otp_register_url {
  struct wire_cst_list_prim_u_8_strict *url;
  struct wire_cst_list_String *recover;
} wire_cst_otp_register_url;

typedef struct wire_cst_user_data_export {
  struct wire_cst_list_prim_u_8_strict *jwt;
  struct wire_cst_list_prim_u_8_strict *user_id;
  struct wire_cst_list_prim_u_8_strict *device_id;
  struct wire_cst_list_prim_u_8_strict *refresh_token;
  struct wire_cst_device_key_data device_keys;
} wire_cst_user_data_export;

typedef struct wire_cst_user_init_server_output {
  struct wire_cst_list_prim_u_8_strict *jwt;
  struct wire_cst_list_group_invite_req_list *invites;
} wire_cst_user_init_server_output;

typedef struct wire_cst_user_login_out {
  struct wire_cst_list_prim_u_8_strict *direct;
  struct wire_cst_list_prim_u_8_strict *master_key;
  struct wire_cst_list_prim_u_8_strict *auth_key;
} wire_cst_user_login_out;

void frbgen_sentc_light_wire__crate__api__user__change_password(int64_t port_,
                                                                struct wire_cst_list_prim_u_8_strict *base_url,
                                                                struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                struct wire_cst_list_prim_u_8_strict *user_identifier,
                                                                struct wire_cst_list_prim_u_8_strict *old_password,
                                                                struct wire_cst_list_prim_u_8_strict *new_password,
                                                                struct wire_cst_list_prim_u_8_strict *mfa_token,
                                                                bool *mfa_recovery);

void frbgen_sentc_light_wire__crate__api__user__check_user_identifier_available(int64_t port_,
                                                                                struct wire_cst_list_prim_u_8_strict *base_url,
                                                                                struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                                struct wire_cst_list_prim_u_8_strict *user_identifier);

void frbgen_sentc_light_wire__crate__api__user__decode_jwt(int64_t port_,
                                                           struct wire_cst_list_prim_u_8_strict *jwt);

void frbgen_sentc_light_wire__crate__api__user__delete_device(int64_t port_,
                                                              struct wire_cst_list_prim_u_8_strict *base_url,
                                                              struct wire_cst_list_prim_u_8_strict *auth_token,
                                                              struct wire_cst_list_prim_u_8_strict *fresh_jwt,
                                                              struct wire_cst_list_prim_u_8_strict *device_id);

void frbgen_sentc_light_wire__crate__api__user__delete_user(int64_t port_,
                                                            struct wire_cst_list_prim_u_8_strict *base_url,
                                                            struct wire_cst_list_prim_u_8_strict *auth_token,
                                                            struct wire_cst_list_prim_u_8_strict *fresh_jwt);

void frbgen_sentc_light_wire__crate__api__user__disable_otp(int64_t port_,
                                                            struct wire_cst_list_prim_u_8_strict *base_url,
                                                            struct wire_cst_list_prim_u_8_strict *auth_token,
                                                            struct wire_cst_list_prim_u_8_strict *jwt);

void frbgen_sentc_light_wire__crate__api__user__done_register(int64_t port_,
                                                              struct wire_cst_list_prim_u_8_strict *server_output);

void frbgen_sentc_light_wire__crate__api__user__done_register_device_start(int64_t port_,
                                                                           struct wire_cst_list_prim_u_8_strict *server_output);

void frbgen_sentc_light_wire__crate__api__user__extract_user_data(int64_t port_,
                                                                  struct wire_cst_list_prim_u_8_strict *data);

void frbgen_sentc_light_wire__crate__api__user__generate_user_register_data(int64_t port_);

void frbgen_sentc_light_wire__crate__api__user__get_fresh_jwt(int64_t port_,
                                                              struct wire_cst_list_prim_u_8_strict *base_url,
                                                              struct wire_cst_list_prim_u_8_strict *auth_token,
                                                              struct wire_cst_list_prim_u_8_strict *user_identifier,
                                                              struct wire_cst_list_prim_u_8_strict *password,
                                                              struct wire_cst_list_prim_u_8_strict *mfa_token,
                                                              bool *mfa_recovery);

void frbgen_sentc_light_wire__crate__api__user__get_otp_recover_keys(int64_t port_,
                                                                     struct wire_cst_list_prim_u_8_strict *base_url,
                                                                     struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                     struct wire_cst_list_prim_u_8_strict *jwt);

void frbgen_sentc_light_wire__crate__api__user__get_user_devices(int64_t port_,
                                                                 struct wire_cst_list_prim_u_8_strict *base_url,
                                                                 struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                 struct wire_cst_list_prim_u_8_strict *jwt,
                                                                 struct wire_cst_list_prim_u_8_strict *last_fetched_time,
                                                                 struct wire_cst_list_prim_u_8_strict *last_fetched_id);

void frbgen_sentc_light_wire__crate__api__group__group_accept_invite(int64_t port_,
                                                                     struct wire_cst_list_prim_u_8_strict *base_url,
                                                                     struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                     struct wire_cst_list_prim_u_8_strict *jwt,
                                                                     struct wire_cst_list_prim_u_8_strict *id,
                                                                     struct wire_cst_list_prim_u_8_strict *group_id,
                                                                     struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_light_wire__crate__api__group__group_accept_join_req(int64_t port_,
                                                                       struct wire_cst_list_prim_u_8_strict *base_url,
                                                                       struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                       struct wire_cst_list_prim_u_8_strict *jwt,
                                                                       struct wire_cst_list_prim_u_8_strict *id,
                                                                       struct wire_cst_list_prim_u_8_strict *user_id,
                                                                       int32_t *rank,
                                                                       int32_t admin_rank,
                                                                       struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_light_wire__crate__api__group__group_create_child_group(int64_t port_,
                                                                          struct wire_cst_list_prim_u_8_strict *base_url,
                                                                          struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                          struct wire_cst_list_prim_u_8_strict *jwt,
                                                                          struct wire_cst_list_prim_u_8_strict *parent_id,
                                                                          int32_t admin_rank,
                                                                          struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_light_wire__crate__api__group__group_create_connected_group(int64_t port_,
                                                                              struct wire_cst_list_prim_u_8_strict *base_url,
                                                                              struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                              struct wire_cst_list_prim_u_8_strict *jwt,
                                                                              struct wire_cst_list_prim_u_8_strict *connected_group_id,
                                                                              int32_t admin_rank,
                                                                              struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_light_wire__crate__api__group__group_create_group(int64_t port_,
                                                                    struct wire_cst_list_prim_u_8_strict *base_url,
                                                                    struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                    struct wire_cst_list_prim_u_8_strict *jwt,
                                                                    struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_light_wire__crate__api__group__group_delete_group(int64_t port_,
                                                                    struct wire_cst_list_prim_u_8_strict *base_url,
                                                                    struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                    struct wire_cst_list_prim_u_8_strict *jwt,
                                                                    struct wire_cst_list_prim_u_8_strict *id,
                                                                    int32_t admin_rank,
                                                                    struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_light_wire__crate__api__group__group_delete_sent_join_req(int64_t port_,
                                                                            struct wire_cst_list_prim_u_8_strict *base_url,
                                                                            struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                            struct wire_cst_list_prim_u_8_strict *jwt,
                                                                            struct wire_cst_list_prim_u_8_strict *id,
                                                                            int32_t admin_rank,
                                                                            struct wire_cst_list_prim_u_8_strict *join_req_group_id,
                                                                            struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_light_wire__crate__api__group__group_delete_sent_join_req_user(int64_t port_,
                                                                                 struct wire_cst_list_prim_u_8_strict *base_url,
                                                                                 struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                                 struct wire_cst_list_prim_u_8_strict *jwt,
                                                                                 struct wire_cst_list_prim_u_8_strict *join_req_group_id,
                                                                                 struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_light_wire__crate__api__group__group_extract_group_data(int64_t port_,
                                                                          struct wire_cst_list_prim_u_8_strict *server_output);

void frbgen_sentc_light_wire__crate__api__group__group_get_all_first_level_children(int64_t port_,
                                                                                    struct wire_cst_list_prim_u_8_strict *base_url,
                                                                                    struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                                    struct wire_cst_list_prim_u_8_strict *jwt,
                                                                                    struct wire_cst_list_prim_u_8_strict *id,
                                                                                    struct wire_cst_list_prim_u_8_strict *last_fetched_time,
                                                                                    struct wire_cst_list_prim_u_8_strict *last_fetched_group_id,
                                                                                    struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_light_wire__crate__api__group__group_get_group_data(int64_t port_,
                                                                      struct wire_cst_list_prim_u_8_strict *base_url,
                                                                      struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                      struct wire_cst_list_prim_u_8_strict *jwt,
                                                                      struct wire_cst_list_prim_u_8_strict *id,
                                                                      struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_light_wire__crate__api__group__group_get_group_updates(int64_t port_,
                                                                         struct wire_cst_list_prim_u_8_strict *base_url,
                                                                         struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                         struct wire_cst_list_prim_u_8_strict *jwt,
                                                                         struct wire_cst_list_prim_u_8_strict *id,
                                                                         struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_light_wire__crate__api__group__group_get_groups_for_user(int64_t port_,
                                                                           struct wire_cst_list_prim_u_8_strict *base_url,
                                                                           struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                           struct wire_cst_list_prim_u_8_strict *jwt,
                                                                           struct wire_cst_list_prim_u_8_strict *last_fetched_time,
                                                                           struct wire_cst_list_prim_u_8_strict *last_fetched_group_id,
                                                                           struct wire_cst_list_prim_u_8_strict *group_id);

void frbgen_sentc_light_wire__crate__api__group__group_get_invites_for_user(int64_t port_,
                                                                            struct wire_cst_list_prim_u_8_strict *base_url,
                                                                            struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                            struct wire_cst_list_prim_u_8_strict *jwt,
                                                                            struct wire_cst_list_prim_u_8_strict *last_fetched_time,
                                                                            struct wire_cst_list_prim_u_8_strict *last_fetched_group_id,
                                                                            struct wire_cst_list_prim_u_8_strict *group_id,
                                                                            struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_light_wire__crate__api__group__group_get_join_reqs(int64_t port_,
                                                                     struct wire_cst_list_prim_u_8_strict *base_url,
                                                                     struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                     struct wire_cst_list_prim_u_8_strict *jwt,
                                                                     struct wire_cst_list_prim_u_8_strict *id,
                                                                     int32_t admin_rank,
                                                                     struct wire_cst_list_prim_u_8_strict *last_fetched_time,
                                                                     struct wire_cst_list_prim_u_8_strict *last_fetched_id,
                                                                     struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_light_wire__crate__api__group__group_get_member(int64_t port_,
                                                                  struct wire_cst_list_prim_u_8_strict *base_url,
                                                                  struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                  struct wire_cst_list_prim_u_8_strict *jwt,
                                                                  struct wire_cst_list_prim_u_8_strict *id,
                                                                  struct wire_cst_list_prim_u_8_strict *last_fetched_time,
                                                                  struct wire_cst_list_prim_u_8_strict *last_fetched_id,
                                                                  struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_light_wire__crate__api__group__group_get_sent_join_req(int64_t port_,
                                                                         struct wire_cst_list_prim_u_8_strict *base_url,
                                                                         struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                         struct wire_cst_list_prim_u_8_strict *jwt,
                                                                         struct wire_cst_list_prim_u_8_strict *id,
                                                                         int32_t admin_rank,
                                                                         struct wire_cst_list_prim_u_8_strict *last_fetched_time,
                                                                         struct wire_cst_list_prim_u_8_strict *last_fetched_group_id,
                                                                         struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_light_wire__crate__api__group__group_get_sent_join_req_user(int64_t port_,
                                                                              struct wire_cst_list_prim_u_8_strict *base_url,
                                                                              struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                              struct wire_cst_list_prim_u_8_strict *jwt,
                                                                              struct wire_cst_list_prim_u_8_strict *last_fetched_time,
                                                                              struct wire_cst_list_prim_u_8_strict *last_fetched_group_id,
                                                                              struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_light_wire__crate__api__group__group_invite_user(int64_t port_,
                                                                   struct wire_cst_list_prim_u_8_strict *base_url,
                                                                   struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                   struct wire_cst_list_prim_u_8_strict *jwt,
                                                                   struct wire_cst_list_prim_u_8_strict *id,
                                                                   struct wire_cst_list_prim_u_8_strict *user_id,
                                                                   int32_t *rank,
                                                                   int32_t admin_rank,
                                                                   bool auto_invite,
                                                                   bool group_invite,
                                                                   struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_light_wire__crate__api__group__group_join_req(int64_t port_,
                                                                struct wire_cst_list_prim_u_8_strict *base_url,
                                                                struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                struct wire_cst_list_prim_u_8_strict *jwt,
                                                                struct wire_cst_list_prim_u_8_strict *id,
                                                                struct wire_cst_list_prim_u_8_strict *group_id,
                                                                struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_light_wire__crate__api__group__group_kick_user(int64_t port_,
                                                                 struct wire_cst_list_prim_u_8_strict *base_url,
                                                                 struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                 struct wire_cst_list_prim_u_8_strict *jwt,
                                                                 struct wire_cst_list_prim_u_8_strict *id,
                                                                 struct wire_cst_list_prim_u_8_strict *user_id,
                                                                 int32_t admin_rank,
                                                                 struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_light_wire__crate__api__group__group_prepare_update_rank(int64_t port_,
                                                                           struct wire_cst_list_prim_u_8_strict *user_id,
                                                                           int32_t rank,
                                                                           int32_t admin_rank);

void frbgen_sentc_light_wire__crate__api__group__group_reject_invite(int64_t port_,
                                                                     struct wire_cst_list_prim_u_8_strict *base_url,
                                                                     struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                     struct wire_cst_list_prim_u_8_strict *jwt,
                                                                     struct wire_cst_list_prim_u_8_strict *id,
                                                                     struct wire_cst_list_prim_u_8_strict *group_id,
                                                                     struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_light_wire__crate__api__group__group_reject_join_req(int64_t port_,
                                                                       struct wire_cst_list_prim_u_8_strict *base_url,
                                                                       struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                       struct wire_cst_list_prim_u_8_strict *jwt,
                                                                       struct wire_cst_list_prim_u_8_strict *id,
                                                                       int32_t admin_rank,
                                                                       struct wire_cst_list_prim_u_8_strict *rejected_user_id,
                                                                       struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_light_wire__crate__api__group__group_stop_group_invites(int64_t port_,
                                                                          struct wire_cst_list_prim_u_8_strict *base_url,
                                                                          struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                          struct wire_cst_list_prim_u_8_strict *jwt,
                                                                          struct wire_cst_list_prim_u_8_strict *id,
                                                                          int32_t admin_rank,
                                                                          struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_light_wire__crate__api__group__group_update_rank(int64_t port_,
                                                                   struct wire_cst_list_prim_u_8_strict *base_url,
                                                                   struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                   struct wire_cst_list_prim_u_8_strict *jwt,
                                                                   struct wire_cst_list_prim_u_8_strict *id,
                                                                   struct wire_cst_list_prim_u_8_strict *user_id,
                                                                   int32_t rank,
                                                                   int32_t admin_rank,
                                                                   struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_light_wire__crate__api__user__init_user(int64_t port_,
                                                          struct wire_cst_list_prim_u_8_strict *base_url,
                                                          struct wire_cst_list_prim_u_8_strict *auth_token,
                                                          struct wire_cst_list_prim_u_8_strict *jwt,
                                                          struct wire_cst_list_prim_u_8_strict *refresh_token);

void frbgen_sentc_light_wire__crate__api__group__leave_group(int64_t port_,
                                                             struct wire_cst_list_prim_u_8_strict *base_url,
                                                             struct wire_cst_list_prim_u_8_strict *auth_token,
                                                             struct wire_cst_list_prim_u_8_strict *jwt,
                                                             struct wire_cst_list_prim_u_8_strict *id,
                                                             struct wire_cst_list_prim_u_8_strict *group_as_member);

void frbgen_sentc_light_wire__crate__api__user__login(int64_t port_,
                                                      struct wire_cst_list_prim_u_8_strict *base_url,
                                                      struct wire_cst_list_prim_u_8_strict *auth_token,
                                                      struct wire_cst_list_prim_u_8_strict *user_identifier,
                                                      struct wire_cst_list_prim_u_8_strict *password);

void frbgen_sentc_light_wire__crate__api__user__mfa_login(int64_t port_,
                                                          struct wire_cst_list_prim_u_8_strict *base_url,
                                                          struct wire_cst_list_prim_u_8_strict *auth_token,
                                                          struct wire_cst_list_prim_u_8_strict *master_key_encryption,
                                                          struct wire_cst_list_prim_u_8_strict *auth_key,
                                                          struct wire_cst_list_prim_u_8_strict *user_identifier,
                                                          struct wire_cst_list_prim_u_8_strict *token,
                                                          bool recovery);

void frbgen_sentc_light_wire__crate__api__user__prepare_register(int64_t port_,
                                                                 struct wire_cst_list_prim_u_8_strict *user_identifier,
                                                                 struct wire_cst_list_prim_u_8_strict *password);

void frbgen_sentc_light_wire__crate__api__user__refresh_jwt(int64_t port_,
                                                            struct wire_cst_list_prim_u_8_strict *base_url,
                                                            struct wire_cst_list_prim_u_8_strict *auth_token,
                                                            struct wire_cst_list_prim_u_8_strict *jwt,
                                                            struct wire_cst_list_prim_u_8_strict *refresh_token);

void frbgen_sentc_light_wire__crate__api__user__register(int64_t port_,
                                                         struct wire_cst_list_prim_u_8_strict *base_url,
                                                         struct wire_cst_list_prim_u_8_strict *auth_token,
                                                         struct wire_cst_list_prim_u_8_strict *user_identifier,
                                                         struct wire_cst_list_prim_u_8_strict *password);

void frbgen_sentc_light_wire__crate__api__user__register_device(int64_t port_,
                                                                struct wire_cst_list_prim_u_8_strict *base_url,
                                                                struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                struct wire_cst_list_prim_u_8_strict *jwt,
                                                                struct wire_cst_list_prim_u_8_strict *server_output);

void frbgen_sentc_light_wire__crate__api__user__register_device_start(int64_t port_,
                                                                      struct wire_cst_list_prim_u_8_strict *base_url,
                                                                      struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                      struct wire_cst_list_prim_u_8_strict *device_identifier,
                                                                      struct wire_cst_list_prim_u_8_strict *password);

void frbgen_sentc_light_wire__crate__api__user__register_otp(int64_t port_,
                                                             struct wire_cst_list_prim_u_8_strict *base_url,
                                                             struct wire_cst_list_prim_u_8_strict *auth_token,
                                                             struct wire_cst_list_prim_u_8_strict *jwt,
                                                             struct wire_cst_list_prim_u_8_strict *issuer,
                                                             struct wire_cst_list_prim_u_8_strict *audience);

void frbgen_sentc_light_wire__crate__api__user__register_raw_otp(int64_t port_,
                                                                 struct wire_cst_list_prim_u_8_strict *base_url,
                                                                 struct wire_cst_list_prim_u_8_strict *auth_token,
                                                                 struct wire_cst_list_prim_u_8_strict *jwt);

void frbgen_sentc_light_wire__crate__api__user__reset_otp(int64_t port_,
                                                          struct wire_cst_list_prim_u_8_strict *base_url,
                                                          struct wire_cst_list_prim_u_8_strict *auth_token,
                                                          struct wire_cst_list_prim_u_8_strict *jwt,
                                                          struct wire_cst_list_prim_u_8_strict *issuer,
                                                          struct wire_cst_list_prim_u_8_strict *audience);

void frbgen_sentc_light_wire__crate__api__user__reset_raw_otp(int64_t port_,
                                                              struct wire_cst_list_prim_u_8_strict *base_url,
                                                              struct wire_cst_list_prim_u_8_strict *auth_token,
                                                              struct wire_cst_list_prim_u_8_strict *jwt);

void frbgen_sentc_light_wire__crate__api__user__update_user(int64_t port_,
                                                            struct wire_cst_list_prim_u_8_strict *base_url,
                                                            struct wire_cst_list_prim_u_8_strict *auth_token,
                                                            struct wire_cst_list_prim_u_8_strict *jwt,
                                                            struct wire_cst_list_prim_u_8_strict *user_identifier);

bool *frbgen_sentc_light_cst_new_box_autoadd_bool(bool value);

int32_t *frbgen_sentc_light_cst_new_box_autoadd_i_32(int32_t value);

struct wire_cst_list_String *frbgen_sentc_light_cst_new_list_String(int32_t len);

struct wire_cst_list_group_children_list *frbgen_sentc_light_cst_new_list_group_children_list(int32_t len);

struct wire_cst_list_group_invite_req_list *frbgen_sentc_light_cst_new_list_group_invite_req_list(int32_t len);

struct wire_cst_list_group_join_req_list *frbgen_sentc_light_cst_new_list_group_join_req_list(int32_t len);

struct wire_cst_list_group_user_list_item *frbgen_sentc_light_cst_new_list_group_user_list_item(int32_t len);

struct wire_cst_list_list_groups *frbgen_sentc_light_cst_new_list_list_groups(int32_t len);

struct wire_cst_list_prim_u_8_strict *frbgen_sentc_light_cst_new_list_prim_u_8_strict(int32_t len);

struct wire_cst_list_user_device_list *frbgen_sentc_light_cst_new_list_user_device_list(int32_t len);
static int64_t dummy_method_to_enforce_bundling(void) {
    int64_t dummy_var = 0;
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_cst_new_box_autoadd_bool);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_cst_new_box_autoadd_i_32);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_cst_new_list_String);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_cst_new_list_group_children_list);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_cst_new_list_group_invite_req_list);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_cst_new_list_group_join_req_list);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_cst_new_list_group_user_list_item);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_cst_new_list_list_groups);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_cst_new_list_prim_u_8_strict);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_cst_new_list_user_device_list);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__group__group_accept_invite);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__group__group_accept_join_req);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__group__group_create_child_group);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__group__group_create_connected_group);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__group__group_create_group);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__group__group_delete_group);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__group__group_delete_sent_join_req);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__group__group_delete_sent_join_req_user);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__group__group_extract_group_data);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__group__group_get_all_first_level_children);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__group__group_get_group_data);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__group__group_get_group_updates);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__group__group_get_groups_for_user);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__group__group_get_invites_for_user);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__group__group_get_join_reqs);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__group__group_get_member);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__group__group_get_sent_join_req);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__group__group_get_sent_join_req_user);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__group__group_invite_user);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__group__group_join_req);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__group__group_kick_user);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__group__group_prepare_update_rank);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__group__group_reject_invite);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__group__group_reject_join_req);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__group__group_stop_group_invites);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__group__group_update_rank);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__group__leave_group);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__user__change_password);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__user__check_user_identifier_available);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__user__decode_jwt);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__user__delete_device);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__user__delete_user);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__user__disable_otp);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__user__done_register);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__user__done_register_device_start);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__user__extract_user_data);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__user__generate_user_register_data);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__user__get_fresh_jwt);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__user__get_otp_recover_keys);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__user__get_user_devices);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__user__init_user);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__user__login);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__user__mfa_login);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__user__prepare_register);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__user__refresh_jwt);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__user__register);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__user__register_device);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__user__register_device_start);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__user__register_otp);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__user__register_raw_otp);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__user__reset_otp);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__user__reset_raw_otp);
    dummy_var ^= ((int64_t) (void*) frbgen_sentc_light_wire__crate__api__user__update_user);
    dummy_var ^= ((int64_t) (void*) store_dart_post_cobject);
    return dummy_var;
}

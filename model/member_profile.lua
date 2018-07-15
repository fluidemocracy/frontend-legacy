MemberProfile = mondelefant.new_class()
MemberProfile.table = 'member_profile'
MemberProfile.primary_key = "member_id"

model.has_rendered_content(MemberProfile, RenderedMemberStatement, "statement", "member_id")


function Auxiliary.PreloadUds()
	local origin_register_effect=Card.RegisterEffect
	Card.RegisterEffect=function(c,e,b)
		if e:IsHasType(0x7f0) then
			local tg=e:GetTarget()
			e:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
				if not tg then return true end
				if chkc then return tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
				if chk==0 then return tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) or not (e:GetHandler():IsType(TYPE_UNION) and e:IsHasType(EFFECT_TYPE_IGNITION)) end --union flag effect is troubling
				return tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
			end)
			if e:IsHasType(EFFECT_TYPE_IGNITION) and not e:IsHasType(EFFECT_TYPE_XMATERIAL) and (e:GetRange()&LOCATION_MZONE)==LOCATION_MZONE then
				local vector={e}
				local cost=e:GetCost()
				local ctlm,ctlmid=e:GetCountLimit()
				local ex=e:Clone()
				ex:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
				ex:SetCode(EVENT_SUMMON_SUCCESS)
				if ctlm and not ctlmid then
					ex:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
						if chk==0 then return not cost or cost(e,tp,eg,ep,ev,re,r,rp,chk) end
						for _,te in ipairs(vector) do
							if te~=e then
								te:UseCountLimit(tp)
							end
						end
						if cost then cost(e,tp,eg,ep,ev,re,r,rp,chk) end
					end)
				end
				table.insert(vector,ex)
				origin_register_effect(c,ex,b)
				local ex2=ex:Clone()
				ex2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
				table.insert(vector,ex2)
				origin_register_effect(c,ex2,b)
				local ex3=ex:Clone()
				ex3:SetCode(EVENT_SPSUMMON_SUCCESS)
				table.insert(vector,ex3)
				origin_register_effect(c,ex3,b)
			end
		end
		origin_register_effect(c,e,b)
	end
end